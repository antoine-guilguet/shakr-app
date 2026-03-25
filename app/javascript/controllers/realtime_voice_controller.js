import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "status"]
  static values = {
    sessionUrl: String
  }

  connect() {
    this.peerConnection = null
    this.mediaStream = null
    this.dataChannel = null
    this.audioEl = null
    this.active = false
    this.setUiIdle()
  }

  disconnect() {
    this.stopSession()
  }

  async toggle(event) {
    event.preventDefault()
    if (this.active) {
      this.stopSession()
    } else {
      await this.startSession()
    }
  }

  setUiIdle() {
    this.active = false
    if (this.hasButtonTarget) {
      this.buttonTarget.disabled = false
      this.buttonTarget.textContent = "Talk to Shakr"
    }
    if (this.hasStatusTarget) this.statusTarget.textContent = ""
  }

  setUiLive() {
    this.active = true
    if (this.hasButtonTarget) {
      this.buttonTarget.disabled = false
      this.buttonTarget.textContent = "End voice"
    }
    if (this.hasStatusTarget) this.statusTarget.textContent = "Listening… speak naturally."
  }

  setUiError(message) {
    this.active = false
    if (this.hasButtonTarget) {
      this.buttonTarget.disabled = false
      this.buttonTarget.textContent = "Talk to Shakr"
    }
    if (this.hasStatusTarget) this.statusTarget.textContent = message
  }

  csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.getAttribute("content")
  }

  async startSession() {
    if (this.hasButtonTarget) this.buttonTarget.disabled = true
    if (this.hasStatusTarget) this.statusTarget.textContent = "Connecting…"

    let ephemeralKey
    let realtimeCallsUrl

    try {
      const res = await fetch(this.sessionUrlValue, {
        method: "POST",
        headers: {
          Accept: "application/json",
          "X-CSRF-Token": this.csrfToken()
        },
        credentials: "same-origin"
      })
      const data = await res.json().catch(() => ({}))
      if (!res.ok) {
        throw new Error(data.error || `Could not start session (${res.status})`)
      }
      ephemeralKey = data.ephemeral_key
      realtimeCallsUrl = data.realtime_calls_url
      if (!ephemeralKey || !realtimeCallsUrl) {
        throw new Error("Invalid response from server.")
      }
    } catch (e) {
      this.setUiError(e.message || "Connection failed.")
      return
    }

    this.peerConnection = new RTCPeerConnection()
    this.audioEl = document.createElement("audio")
    this.audioEl.autoplay = true
    this.element.appendChild(this.audioEl)

    this.peerConnection.ontrack = (e) => {
      this.audioEl.srcObject = e.streams[0]
    }

    this.peerConnection.onconnectionstatechange = () => {
      if (this.peerConnection?.connectionState === "failed") {
        this.setUiError("Connection lost.")
        this.stopSession()
      }
    }

    try {
      this.mediaStream = await navigator.mediaDevices.getUserMedia({ audio: true })
    } catch {
      this.setUiError("Microphone permission is required.")
      this.cleanupPeer()
      return
    }

    this.mediaStream.getTracks().forEach((track) => this.peerConnection.addTrack(track, this.mediaStream))

    this.dataChannel = this.peerConnection.createDataChannel("oai-events")
    this.dataChannel.addEventListener("message", (e) => {
      try {
        const event = JSON.parse(e.data)
        if (event.type === "error") {
          console.warn("[oai-events]", event)
        } else {
          console.debug("[oai-events]", event.type, event)
        }
      } catch {
        /* ignore */
      }
    })

    const offer = await this.peerConnection.createOffer()
    await this.peerConnection.setLocalDescription(offer)

    let sdpResponse
    try {
      sdpResponse = await fetch(realtimeCallsUrl, {
        method: "POST",
        body: offer.sdp,
        headers: {
          Authorization: `Bearer ${ephemeralKey}`,
          "Content-Type": "application/sdp"
        }
      })
    } catch {
      this.setUiError("Could not reach OpenAI.")
      this.stopSession()
      return
    }

    if (!sdpResponse.ok) {
      const errText = await sdpResponse.text()
      console.error("[Realtime] SDP error", sdpResponse.status, errText)
      this.setUiError("OpenAI rejected the connection.")
      this.stopSession()
      return
    }

    const answer = {
      type: "answer",
      sdp: await sdpResponse.text()
    }
    await this.peerConnection.setRemoteDescription(answer)

    this.setUiLive()
    if (this.hasButtonTarget) this.buttonTarget.disabled = false
  }

  stopSession() {
    this.cleanupPeer()
    this.setUiIdle()
  }

  cleanupPeer() {
    if (this.dataChannel) {
      try {
        this.dataChannel.close()
      } catch {
        /* ignore */
      }
      this.dataChannel = null
    }

    if (this.mediaStream) {
      this.mediaStream.getTracks().forEach((t) => t.stop())
      this.mediaStream = null
    }

    if (this.peerConnection) {
      this.peerConnection.close()
      this.peerConnection = null
    }

    if (this.audioEl) {
      this.audioEl.srcObject = null
      this.audioEl.remove()
      this.audioEl = null
    }
  }
}
