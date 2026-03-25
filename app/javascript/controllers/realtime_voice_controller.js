import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "status", "transcript"]
  static values = {
    sessionUrl: String
  }

  connect() {
    this.peerConnection = null
    this.mediaStream = null
    this.dataChannel = null
    this.audioEl = null
    this.active = false
    this.drafts = new Map()
    this.functionArgDeltas = new Map()
    this.handledCallIds = new Set()
    this.currentDraftRecipe = null
    this.currentDraftRecipeId = null
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

  ensureDraft(key, role) {
    if (!this.hasTranscriptTarget) return null
    if (this.drafts.has(key)) return this.drafts.get(key)

    const row = document.createElement("div")
    row.className = `voice-msg voice-msg--${role} voice-msg--draft`
    row.dataset.draftKey = key

    const who = document.createElement("div")
    who.className = "voice-msg__who"
    who.textContent = role === "user" ? "You" : "Shakr"

    const body = document.createElement("div")
    body.className = "voice-msg__body"
    body.textContent = ""

    row.appendChild(who)
    row.appendChild(body)
    this.transcriptTarget.appendChild(row)
    this.drafts.set(key, row)
    this.scrollTranscriptToBottom()
    return row
  }

  appendDraftText(key, role, delta) {
    if (!delta) return
    const row = this.ensureDraft(key, role)
    if (!row) return
    const body = row.querySelector(".voice-msg__body")
    body.textContent += delta
    this.scrollTranscriptToBottom()
  }

  finalizeDraft(key, finalText) {
    const row = this.drafts.get(key)
    if (!row) return
    const body = row.querySelector(".voice-msg__body")
    if (typeof finalText === "string" && finalText.length > 0) {
      body.textContent = finalText
    }
    row.classList.remove("voice-msg--draft")
    this.drafts.delete(key)
    this.scrollTranscriptToBottom()
  }

  scrollTranscriptToBottom() {
    if (!this.hasTranscriptTarget) return
    this.transcriptTarget.scrollTop = this.transcriptTarget.scrollHeight
  }

  sendRealtimeEvent(payload) {
    if (!this.dataChannel || this.dataChannel.readyState !== "open") return false
    try {
      this.dataChannel.send(JSON.stringify(payload))
      return true
    } catch {
      return false
    }
  }

  async handleFunctionCall({ name, callId, argumentsJson }) {
    if (!name || !callId) return
    if (this.handledCallIds.has(callId)) return
    this.handledCallIds.add(callId)

    let args = {}
    if (typeof argumentsJson === "string" && argumentsJson.length > 0) {
      try {
        args = JSON.parse(argumentsJson)
      } catch {
        args = {}
      }
    }

    let result
    try {
      const res = await fetch(`/agent/tools/${encodeURIComponent(name)}`, {
        method: "POST",
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken()
        },
        credentials: "same-origin",
        body: JSON.stringify(args)
      })

      result = await res.json().catch(() => null)
      if (!res.ok) {
        result = result || {}
        result.error = result.error || `Tool failed (${res.status})`
      }
    } catch (e) {
      result = { error: e?.message || "Tool request failed." }
    }

    if (name === "recipes_search" && result?.found && result?.recipe) {
      this.appendRecipeCard(result.recipe)
    }

    if (name === "create_ai_recipe" && result?.ok && result?.recipe) {
      this.currentDraftRecipe = result.recipe
      this.currentDraftRecipeId =
        (globalThis.crypto && typeof globalThis.crypto.randomUUID === "function" && globalThis.crypto.randomUUID()) ||
        `draft_${Date.now()}_${Math.random().toString(16).slice(2)}`
      this.appendAiRecipeCard(result.recipe, { draftId: this.currentDraftRecipeId })
    }

    this.sendRealtimeEvent({
      type: "conversation.item.create",
      item: {
        type: "function_call_output",
        call_id: callId,
        output: JSON.stringify(result || {})
      }
    })

    this.sendRealtimeEvent({ type: "response.create" })
  }

  appendRecipeCard(recipe) {
    if (!this.hasTranscriptTarget || !recipe) return

    const row = document.createElement("div")
    row.className = "voice-msg voice-msg--tool"

    const who = document.createElement("div")
    who.className = "voice-msg__who"
    who.textContent = "Shakr"

    const body = document.createElement("div")
    body.className = "voice-msg__body"

    const title = document.createElement("div")
    title.className = "voice-recipe-card__title"

    const link = document.createElement("a")
    link.href = recipe.url || "#"
    link.textContent = recipe.name || "Recipe"
    link.className = "voice-recipe-card__link"

    const badge = document.createElement("span")
    badge.className = `voice-recipe-card__badge ${recipe.is_public ? "voice-recipe-card__badge--public" : "voice-recipe-card__badge--private"}`
    badge.textContent = recipe.is_public ? "Public" : "Private"

    title.appendChild(link)
    title.appendChild(badge)

    const desc = document.createElement("div")
    desc.className = "voice-recipe-card__desc"
    desc.textContent = (recipe.description || "").toString()

    body.appendChild(title)
    if (desc.textContent.length > 0) body.appendChild(desc)

    row.appendChild(who)
    row.appendChild(body)
    this.transcriptTarget.appendChild(row)
    this.scrollTranscriptToBottom()
  }

  appendAiRecipeCard(recipe, { draftId } = {}) {
    if (!this.hasTranscriptTarget || !recipe) return

    const row = document.createElement("div")
    row.className = "voice-msg voice-msg--tool"
    if (draftId) row.dataset.draftId = draftId

    const who = document.createElement("div")
    who.className = "voice-msg__who"
    who.textContent = "Shakr"

    const body = document.createElement("div")
    body.className = "voice-msg__body"

    const title = document.createElement("div")
    title.className = "voice-recipe-card__title"

    const name = document.createElement("div")
    name.className = "voice-recipe-card__name"
    name.textContent = recipe.name || "Draft recipe"

    const badge = document.createElement("span")
    badge.className = "voice-recipe-card__badge voice-recipe-card__badge--draft"
    badge.textContent = "Draft"

    title.appendChild(name)
    title.appendChild(badge)

    const desc = document.createElement("div")
    desc.className = "voice-recipe-card__desc"
    desc.textContent = (recipe.description || "").toString()

    const ingredients = Array.isArray(recipe.ingredients) ? recipe.ingredients : []
    const steps = Array.isArray(recipe.steps) ? recipe.steps : []

    const ingList = document.createElement("ul")
    ingList.className = "voice-recipe-card__list"
    for (const ing of ingredients) {
      const li = document.createElement("li")
      const qty = ing?.quantity ? `${ing.quantity}` : ""
      const unit = ing?.unit ? `${ing.unit}` : ""
      const ingName = ing?.name ? `${ing.name}` : ""
      li.textContent = [qty, unit, ingName].filter(Boolean).join(" ").trim()
      if (li.textContent.length > 0) ingList.appendChild(li)
    }

    const stepsList = document.createElement("ol")
    stepsList.className = "voice-recipe-card__list voice-recipe-card__steps"
    steps.slice(0, 2).forEach((s) => {
      const li = document.createElement("li")
      li.textContent = s.toString()
      stepsList.appendChild(li)
    })

    body.appendChild(title)
    if (desc.textContent.length > 0) body.appendChild(desc)
    if (ingList.childElementCount > 0) {
      const h = document.createElement("div")
      h.className = "voice-recipe-card__section"
      h.textContent = "Ingredients"
      body.appendChild(h)
      body.appendChild(ingList)
    }
    if (stepsList.childElementCount > 0) {
      const h = document.createElement("div")
      h.className = "voice-recipe-card__section"
      h.textContent = "Steps (preview)"
      body.appendChild(h)
      body.appendChild(stepsList)
    }

    row.appendChild(who)
    row.appendChild(body)
    this.transcriptTarget.appendChild(row)
    this.scrollTranscriptToBottom()
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
        if (event.type === "conversation.item.input_audio_transcription.delta") {
          const key = `user:${event.item_id || "unknown"}`
          this.appendDraftText(key, "user", event.delta)
          return
        }

        if (event.type === "conversation.item.input_audio_transcription.completed") {
          const key = `user:${event.item_id || "unknown"}`
          this.finalizeDraft(key, event.transcript)
          return
        }

        if (event.type === "response.text.delta") {
          const key = `assistant:${event.response_id || "current"}`
          this.appendDraftText(key, "assistant", event.delta)
          return
        }

        if (event.type === "response.output_audio_transcript.delta") {
          const key = `assistant:${event.response_id || "current"}`
          this.appendDraftText(key, "assistant", event.delta)
          return
        }

        if (event.type === "response.output_audio_transcript.done") {
          const key = `assistant:${event.response_id || "current"}`
          this.finalizeDraft(key, event.transcript)
          return
        }

        if (event.type === "response.completed") {
          const key = `assistant:${event.response_id || "current"}`
          this.finalizeDraft(key)
          return
        }

        if (event.type === "response.function_call_arguments.delta") {
          const callId = event.call_id
          if (callId) {
            const prev = this.functionArgDeltas.get(callId) || ""
            this.functionArgDeltas.set(callId, prev + (event.delta || ""))
          }
          return
        }

        if (event.type === "response.function_call_arguments.done") {
          const callId = event.call_id
          const name = event.name
          const argsJson = typeof event.arguments === "string" ? event.arguments : (this.functionArgDeltas.get(callId) || "")
          this.functionArgDeltas.delete(callId)
          this.handleFunctionCall({ name, callId, argumentsJson: argsJson })
          return
        }

        // Fallback path: tool calls can also appear in `response.done`
        if (event.type === "response.done") {
          const output = event?.response?.output || []
          for (const item of output) {
            if (item?.type === "function_call") {
              this.handleFunctionCall({
                name: item.name,
                callId: item.call_id,
                argumentsJson: item.arguments
              })
            }
          }
          return
        }

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
    this.drafts?.clear?.()
    this.functionArgDeltas?.clear?.()
    this.handledCallIds?.clear?.()

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
