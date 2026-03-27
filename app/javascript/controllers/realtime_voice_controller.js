import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "status", "summarySection", "summary", "recipeSection", "recipe", "actionsSection", "actions"]
  static values = {
    sessionUrl: String
  }

  connect() {
    this.peerConnection = null
    this.mediaStream = null
    this.dataChannel = null
    this.audioEl = null
    this.active = false
    this.functionArgDeltas = new Map()
    this.handledCallIds = new Set()
    this.uiState = {
      summary: null,
      recipe: null,
      actions: []
    }
    this.setUiIdle()
    this.renderUiState()
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
    if (this.hasStatusTarget) this.statusTarget.textContent = "Listening..."
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

    if (name === "ui_state_update" && result?.ok) {
      this.applyUiStateUpdate(result)
    }

    if (name === "recipes_search" && result?.found && result?.recipe) {
      this.applyUiStateUpdate({
        recipe: {
          name: result.recipe.name,
          description: result.recipe.description,
          badge: result.recipe.is_public ? "Public" : "Private",
          url: result.recipe.url,
          ingredients: [],
          steps_preview: []
        }
      })
    }

    if (name === "create_ai_recipe" && result?.ok && result?.recipe) {
      this.applyUiStateUpdate({
        recipe: {
          name: result.recipe.name,
          description: result.recipe.description,
          badge: "Draft",
          ingredients: Array(result.recipe.ingredients).map((ing) => {
            const qty = ing?.quantity ? `${ing.quantity}` : ""
            const unit = ing?.unit ? `${ing.unit}` : ""
            const ingName = ing?.name ? `${ing.name}` : ""
            return [qty, unit, ingName].filter(Boolean).join(" ").trim()
          }).filter(Boolean),
          steps_preview: Array(result.recipe.steps).slice(0, 2).map((step) => step.toString())
        }
      })
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

  applyUiStateUpdate(payload) {
    if (typeof payload.summary === "string") this.uiState.summary = payload.summary
    if (Array.isArray(payload.actions)) this.uiState.actions = payload.actions
    if (Object.prototype.hasOwnProperty.call(payload, "recipe")) this.uiState.recipe = payload.recipe
    this.renderUiState()
  }

  renderUiState() {
    this.renderSummary()
    this.renderRecipe()
    this.renderActions()
  }

  renderSummary() {
    const summary = this.uiState.summary?.toString().trim()
    const hasSummary = Boolean(summary)
    if (this.hasSummaryTarget) this.summaryTarget.textContent = hasSummary ? summary : ""
    if (this.hasSummarySectionTarget) this.summarySectionTarget.hidden = !hasSummary
  }

  renderRecipe() {
    if (!this.hasRecipeTarget) return
    const recipe = this.uiState.recipe
    this.recipeTarget.innerHTML = ""

    if (!recipe || !recipe.name) {
      if (this.hasRecipeSectionTarget) this.recipeSectionTarget.hidden = true
      return
    }

    if (this.hasRecipeSectionTarget) this.recipeSectionTarget.hidden = false

    const card = document.createElement("div")
    card.className = "voice-recipe-card"

    const title = document.createElement("div")
    title.className = "voice-recipe-card__title"

    if (recipe.url) {
      const link = document.createElement("a")
      link.href = recipe.url
      link.className = "voice-recipe-card__link"
      link.textContent = recipe.name || "Recipe"
      title.appendChild(link)
    } else {
      const name = document.createElement("div")
      name.className = "voice-recipe-card__name"
      name.textContent = recipe.name || "Recipe"
      title.appendChild(name)
    }

    if (recipe.badge) {
      const badge = document.createElement("span")
      badge.className = "voice-recipe-card__badge"
      badge.textContent = recipe.badge
      title.appendChild(badge)
    }

    card.appendChild(title)

    if (recipe.description) {
      const desc = document.createElement("div")
      desc.className = "voice-recipe-card__desc"
      desc.textContent = recipe.description.toString()
      card.appendChild(desc)
    }

    const ingredients = Array.isArray(recipe.ingredients) ? recipe.ingredients : []
    if (ingredients.length > 0) {
      const section = document.createElement("div")
      section.className = "voice-recipe-card__section"
      section.textContent = "Ingredients"
      card.appendChild(section)

      const list = document.createElement("ul")
      list.className = "voice-recipe-card__list"
      ingredients.forEach((ing) => {
        const li = document.createElement("li")
        li.textContent = ing.toString()
        list.appendChild(li)
      })
      card.appendChild(list)
    }

    const steps = Array.isArray(recipe.steps_preview) ? recipe.steps_preview : []
    if (steps.length > 0) {
      const section = document.createElement("div")
      section.className = "voice-recipe-card__section"
      section.textContent = "Steps (preview)"
      card.appendChild(section)

      const list = document.createElement("ol")
      list.className = "voice-recipe-card__list voice-recipe-card__steps"
      steps.forEach((step) => {
        const li = document.createElement("li")
        li.textContent = step.toString()
        list.appendChild(li)
      })
      card.appendChild(list)
    }

    this.recipeTarget.appendChild(card)
  }

  renderActions() {
    if (!this.hasActionsTarget) return
    this.actionsTarget.innerHTML = ""
    const actions = Array.isArray(this.uiState.actions) ? this.uiState.actions : []
    const validActions = actions.filter((action) => action?.label && action?.utterance)

    if (this.hasActionsSectionTarget) this.actionsSectionTarget.hidden = validActions.length === 0
    validActions.forEach((action) => {
      const button = document.createElement("button")
      button.type = "button"
      button.className = "voice-ui-action"
      button.dataset.action = "click->realtime-voice#runSuggestedAction"
      button.dataset.utterance = action.utterance.toString()
      button.textContent = action.label.toString()
      this.actionsTarget.appendChild(button)
    })
  }

  runSuggestedAction(event) {
    event.preventDefault()
    const utterance = event.currentTarget?.dataset?.utterance
    if (!utterance) return
    this.sendUserText(utterance)
  }

  sendUserText(text) {
    const utterance = text.toString().trim()
    if (!utterance) return

    const ok = this.sendRealtimeEvent({
      type: "conversation.item.create",
      item: {
        type: "message",
        role: "user",
        content: [{ type: "input_text", text: utterance }]
      }
    })

    if (!ok) return
    this.sendRealtimeEvent({ type: "response.create" })
    if (this.hasStatusTarget) this.statusTarget.textContent = "Thinking..."
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
        if (event.type === "response.created") {
          if (this.hasStatusTarget) this.statusTarget.textContent = "Thinking..."
          return
        }

        if (event.type === "response.completed") {
          if (this.hasStatusTarget) this.statusTarget.textContent = "Listening..."
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
