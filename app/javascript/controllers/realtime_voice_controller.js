import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "button",
    "buttonLabel",
    "buttonState",
    "status",
    "summarySection",
    "summary",
    "recipeSection",
    "recipeCard",
    "recipeTrack",
    "recipePrevBtn",
    "recipeNextBtn",
    "recipeIndicator",
    "recipeName",
    "recipeLink",
    "recipeBadge",
    "recipeDescription",
    "recipeIngredients",
    "recipeIngredientsHint",
    "recipeSteps",
    "recipeStepsHint",
    "actionsSection",
    "actions"
  ]
  static values = {
    sessionUrl: String,
    autostart: { type: Boolean, default: false }
  }

  connect() {
    this.peerConnection = null
    this.mediaStream = null
    this.dataChannel = null
    this.audioEl = null
    this.active = false
    this.autostartAttempted = false
    this.functionArgDeltas = new Map()
    this.handledCallIds = new Set()
    this.voiceState = { session: "idle", phase: "idle", message: "" }
    this.uiState = {
      summary: null,
      recipe: null,
      actions: [],
      display: null,
      recipe_mode: null,
      current_step_index: null,
      total_steps: null
    }
    this.currentRecipeSlideIndex = 0
    this.setUiIdle()
    this.renderUiState()
    if (this.autostartValue) {
      queueMicrotask(() => this.runAutostart())
    }
  }

  async runAutostart() {
    if (this.autostartAttempted) return
    this.autostartAttempted = true
    try {
      await this.startSession()
    } catch {
      /* startSession handles UI errors */
    }
  }

  stripAutostartFromUrl() {
    try {
      const url = new URL(window.location.href)
      if (!url.searchParams.has("autostart")) return
      url.searchParams.delete("autostart")
      const qs = url.searchParams.toString()
      const next = `${url.pathname}${qs ? `?${qs}` : ""}${url.hash}`
      window.history.replaceState(null, "", next)
    } catch {
      /* ignore */
    }
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

  setVoiceState(next) {
    const current = this.voiceState || { session: "idle", phase: "idle", message: "" }
    this.voiceState = {
      session: next?.session || current.session,
      phase: next?.phase || current.phase,
      message: typeof next?.message === "string" ? next.message : current.message
    }
    this.renderVoiceState()
  }

  voiceStateStatusText() {
    const s = this.voiceState?.session
    const p = this.voiceState?.phase
    const m = this.voiceState?.message

    if (typeof m === "string" && m.trim().length > 0) return m.trim()
    if (s === "connecting") return "Connecting…"
    if (s === "error") return "Error."
    if (s === "idle") return ""
    if (p === "thinking") return "Thinking…"
    if (p === "listening") return "Listening…"
    return ""
  }

  renderVoiceState() {
    const s = this.voiceState?.session || "idle"
    const p = this.voiceState?.phase || "idle"

    const active = s === "live"
    const phaseForFab = s === "connecting" ? "connecting" : s === "error" ? "error" : active ? p : "idle"
    const label = active ? "End voice" : s === "connecting" ? "Starting…" : "Talk to Shakr"
    const stateText = phaseForFab === "connecting" ? "Connecting" : phaseForFab === "thinking" ? "Thinking" : phaseForFab === "listening" ? "Listening" : phaseForFab === "error" ? "Error" : ""
    const busy = s === "connecting" || (active && p === "thinking")

    this.setFabState({ phase: phaseForFab, active, label, stateText, busy })

    if (this.hasStatusTarget) {
      this.statusTarget.textContent = this.voiceStateStatusText()
    }
  }

  setFabState({ phase, active, label, stateText, busy }) {
    const nextPhase = phase || "idle"

    if (this.hasButtonTarget) {
      this.buttonTarget.dataset.voiceState = nextPhase
      this.buttonTarget.dataset.voiceActive = active ? "true" : "false"
      if (typeof busy === "boolean") {
        this.buttonTarget.setAttribute("aria-busy", busy ? "true" : "false")
      } else {
        this.buttonTarget.removeAttribute("aria-busy")
      }
      if (typeof label === "string" && this.hasButtonLabelTarget) {
        this.buttonLabelTarget.textContent = label
      } else if (typeof label === "string") {
        this.buttonTarget.textContent = label
      }
      if (this.hasButtonStateTarget) {
        this.buttonStateTarget.textContent = stateText ? stateText.toString() : ""
      }
    }
  }

  setUiIdle() {
    this.active = false
    if (this.hasButtonTarget) {
      this.buttonTarget.disabled = false
      this.setVoiceState({ session: "idle", phase: "idle", message: "" })
    }
  }

  setUiLive() {
    this.active = true
    if (this.hasButtonTarget) {
      this.buttonTarget.disabled = false
      this.setVoiceState({ session: "live", phase: "listening", message: "" })
    }
  }

  setUiError(message) {
    this.active = false
    if (this.hasButtonTarget) {
      this.buttonTarget.disabled = false
      this.setVoiceState({ session: "error", phase: "error", message: message?.toString?.() || "Error." })
    }
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
      const r = result.recipe
      this.applyUiStateUpdate({
        recipe: {
          name: r.name,
          description: r.description,
          badge: r.is_public ? "Public" : "Private",
          url: r.url,
          ingredients: Array.isArray(r.ingredients) ? r.ingredients : [],
          steps_preview: Array.isArray(r.steps_preview) ? r.steps_preview : []
        }
      })
    }

    if (name === "create_ai_recipe" && result?.ok && result?.recipe) {
      this.applyUiStateUpdate({
        recipe: {
          name: result.recipe.name,
          description: result.recipe.description,
          badge: "Draft",
          ingredients: (Array.isArray(result.recipe.ingredients) ? result.recipe.ingredients : []).map((ing) => {
            const qty = ing?.quantity ? `${ing.quantity}` : ""
            const unit = ing?.unit ? `${ing.unit}` : ""
            const ingName = ing?.name ? `${ing.name}` : ""
            return [qty, unit, ingName].filter(Boolean).join(" ").trim()
          }).filter(Boolean),
          steps_preview: (Array.isArray(result.recipe.steps) ? result.recipe.steps : []).map((step) => step.toString()).filter(Boolean)
        }
      })
    }

    if (name === "update_recipe" && result?.ok && result?.recipe) {
      const r = result.recipe
      const badge = result.forked ? "Yours (copy)" : r.is_public ? "Public" : "Private"
      this.applyUiStateUpdate({
        recipe: {
          name: r.name,
          description: r.description,
          badge,
          url: r.url,
          ingredients: Array.isArray(r.ingredients) ? r.ingredients : [],
          steps_preview: Array.isArray(r.steps_preview) ? r.steps_preview : []
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
    if (Object.prototype.hasOwnProperty.call(payload, "recipe")) {
      const nextRecipe = payload.recipe
      if (nextRecipe && typeof nextRecipe === "object" && this.uiState.recipe && typeof this.uiState.recipe === "object") {
        // Merge to avoid wiping fields like steps_preview when the assistant sends a partial recipe payload.
        this.uiState.recipe = { ...this.uiState.recipe, ...nextRecipe }
      } else {
        this.uiState.recipe = nextRecipe
      }
    }
    if (typeof payload.display === "string") this.uiState.display = payload.display
    if (typeof payload.recipe_mode === "string") this.uiState.recipe_mode = payload.recipe_mode
    if (typeof payload.current_step_index === "number") this.uiState.current_step_index = payload.current_step_index
    if (typeof payload.total_steps === "number") this.uiState.total_steps = payload.total_steps
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
    const recipe = this.uiState.recipe
    this.currentRecipeSlideIndex = 0

    if (!recipe || !recipe.name) {
      if (this.hasRecipeSectionTarget) this.recipeSectionTarget.hidden = true
      return
    }

    if (this.hasRecipeSectionTarget) this.recipeSectionTarget.hidden = false
    this.fillRecipeCard(recipe)

    // Optional hint: auto-switch panel for guided mode
    if (this.uiState.display === "steps") {
      this.currentRecipeSlideIndex = 1
    }
    this.updateRecipeSliderUi()
  }

  fillRecipeCard(recipe) {
    if (this.hasRecipeCardTarget) this.recipeCardTarget.hidden = false

    const nameText = recipe?.name ? recipe.name.toString() : "Recipe"
    const badgeText = recipe?.badge ? recipe.badge.toString().trim() : ""
    const descText = recipe?.description ? recipe.description.toString().trim() : ""
    const urlText = recipe?.url ? recipe.url.toString().trim() : ""

    if (urlText) {
      if (this.hasRecipeLinkTarget) {
        this.recipeLinkTarget.hidden = false
        this.recipeLinkTarget.href = urlText
        this.recipeLinkTarget.textContent = nameText
      }
      if (this.hasRecipeNameTarget) this.recipeNameTarget.hidden = true
    } else {
      if (this.hasRecipeNameTarget) {
        this.recipeNameTarget.hidden = false
        this.recipeNameTarget.textContent = nameText
      }
      if (this.hasRecipeLinkTarget) this.recipeLinkTarget.hidden = true
    }

    if (this.hasRecipeBadgeTarget) {
      this.recipeBadgeTarget.hidden = !badgeText
      this.recipeBadgeTarget.textContent = badgeText
    }

    if (this.hasRecipeDescriptionTarget) {
      this.recipeDescriptionTarget.hidden = !descText
      this.recipeDescriptionTarget.textContent = descText
    }

    const ingredients = Array.isArray(recipe?.ingredients) ? recipe.ingredients : []
    if (this.hasRecipeIngredientsTarget) {
      this.recipeIngredientsTarget.innerHTML = ""
      ingredients.forEach((ing) => {
        const li = document.createElement("li")
        li.textContent = ing.toString()
        this.recipeIngredientsTarget.appendChild(li)
      })
      this.recipeIngredientsTarget.hidden = ingredients.length === 0
    }
    if (this.hasRecipeIngredientsHintTarget) {
      this.recipeIngredientsHintTarget.hidden = ingredients.length > 0
    }

    const steps = Array.isArray(recipe?.steps_preview) ? recipe.steps_preview : []
    if (this.hasRecipeStepsTarget) {
      this.recipeStepsTarget.innerHTML = ""
      const activeIdx = Number.isInteger(this.uiState.current_step_index) ? this.uiState.current_step_index : null
      steps.forEach((step, idx) => {
        const li = document.createElement("li")
        li.textContent = step.toString()
        if (activeIdx !== null && idx === activeIdx) {
          li.classList.add("is-active-step")
        }
        this.recipeStepsTarget.appendChild(li)
      })
      this.recipeStepsTarget.hidden = steps.length === 0
    }
    if (this.hasRecipeStepsHintTarget) {
      this.recipeStepsHintTarget.hidden = steps.length > 0
    }
  }

  goToRecipeSlide(index) {
    this.currentRecipeSlideIndex = Math.max(0, Math.min(1, index))
    this.updateRecipeSliderUi()
  }

  nextRecipeSlide(event) {
    event.preventDefault()
    this.goToRecipeSlide(this.currentRecipeSlideIndex + 1)
  }

  prevRecipeSlide(event) {
    event.preventDefault()
    this.goToRecipeSlide(this.currentRecipeSlideIndex - 1)
  }

  updateRecipeSliderUi() {
    if (!this.hasRecipeTrackTarget || !this.hasRecipeIndicatorTarget || !this.hasRecipePrevBtnTarget || !this.hasRecipeNextBtnTarget) return

    const track = this.recipeTrackTarget
    const indicator = this.recipeIndicatorTarget
    const prevBtn = this.recipePrevBtnTarget
    const nextBtn = this.recipeNextBtnTarget
    const pct = this.currentRecipeSlideIndex === 0 ? "0%" : "-50%"
    track.style.transform = `translateX(${pct})`
    indicator.textContent = `${this.currentRecipeSlideIndex + 1} / 2`
    prevBtn.disabled = this.currentRecipeSlideIndex === 0
    nextBtn.disabled = this.currentRecipeSlideIndex === 1
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
    if (this.active) {
      this.setVoiceState({ session: "live", phase: "thinking", message: "" })
    }
  }

  async startSession() {
    if (this.hasButtonTarget) this.buttonTarget.disabled = true
    this.setVoiceState({ session: "connecting", phase: "connecting", message: "" })

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
          if (this.active) {
            this.setVoiceState({ session: "live", phase: "thinking", message: "" })
          }
          return
        }

        if (event.type === "response.completed") {
          if (this.active) {
            this.setVoiceState({ session: "live", phase: "listening", message: "" })
          }
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
    this.stripAutostartFromUrl()
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
