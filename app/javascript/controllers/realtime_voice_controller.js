import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "status", "summarySection", "summary", "recipeSection", "recipe", "actionsSection", "actions"]
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
    this.uiState = {
      summary: null,
      recipe: null,
      actions: []
    }
    this.currentRecipeSlideIndex = 0
    this.recipeSliderRefs = null
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
          ingredients: Array(result.recipe.ingredients).map((ing) => {
            const qty = ing?.quantity ? `${ing.quantity}` : ""
            const unit = ing?.unit ? `${ing.unit}` : ""
            const ingName = ing?.name ? `${ing.name}` : ""
            return [qty, unit, ingName].filter(Boolean).join(" ").trim()
          }).filter(Boolean),
          steps_preview: Array(result.recipe.steps).map((step) => step.toString())
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
    this.recipeSliderRefs = null
    this.currentRecipeSlideIndex = 0

    if (!recipe || !recipe.name) {
      if (this.hasRecipeSectionTarget) this.recipeSectionTarget.hidden = true
      return
    }

    if (this.hasRecipeSectionTarget) this.recipeSectionTarget.hidden = false

    const card = this.buildRecipeSliderCard(recipe)
    this.recipeTarget.appendChild(card)
    this.updateRecipeSliderUi()
  }

  buildRecipeSliderCard(recipe) {
    const card = document.createElement("div")
    card.className = "voice-recipe-card voice-recipe-card--fancy"

    const slider = document.createElement("div")
    slider.className = "voice-recipe-card__slider"

    const track = document.createElement("div")
    track.className = "voice-recipe-card__track"
    track.setAttribute("role", "region")
    track.setAttribute("aria-label", "Recipe details")

    const slideOverview = document.createElement("div")
    slideOverview.className = "voice-recipe-card__slide voice-recipe-card__slide--overview"
    slideOverview.appendChild(this.buildRecipeOverviewContent(recipe))

    const slideSteps = document.createElement("div")
    slideSteps.className = "voice-recipe-card__slide voice-recipe-card__slide--steps"
    slideSteps.appendChild(this.buildRecipeStepsContent(recipe))

    track.appendChild(slideOverview)
    track.appendChild(slideSteps)
    slider.appendChild(track)

    const controls = document.createElement("div")
    controls.className = "voice-recipe-card__slider-controls"

    const prevBtn = document.createElement("button")
    prevBtn.type = "button"
    prevBtn.className = "voice-recipe-card__slider-btn"
    prevBtn.setAttribute("aria-label", "Previous slide")
    prevBtn.textContent = "Prev"
    prevBtn.dataset.action = "click->realtime-voice#prevRecipeSlide"

    const indicator = document.createElement("span")
    indicator.className = "voice-recipe-card__slider-indicator"
    indicator.setAttribute("aria-live", "polite")

    const nextBtn = document.createElement("button")
    nextBtn.type = "button"
    nextBtn.className = "voice-recipe-card__slider-btn"
    nextBtn.setAttribute("aria-label", "Next slide")
    nextBtn.textContent = "Next"
    nextBtn.dataset.action = "click->realtime-voice#nextRecipeSlide"

    controls.appendChild(prevBtn)
    controls.appendChild(indicator)
    controls.appendChild(nextBtn)

    card.appendChild(slider)
    card.appendChild(controls)

    this.recipeSliderRefs = { track, indicator, prevBtn, nextBtn }

    return card
  }

  buildRecipeOverviewContent(recipe) {
    const wrap = document.createElement("div")
    wrap.className = "voice-recipe-card__slide-inner"

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

    wrap.appendChild(title)

    if (recipe.description) {
      const desc = document.createElement("div")
      desc.className = "voice-recipe-card__desc"
      desc.textContent = recipe.description.toString()
      wrap.appendChild(desc)
    }

    const ingredients = Array.isArray(recipe.ingredients) ? recipe.ingredients : []
    const section = document.createElement("div")
    section.className = "voice-recipe-card__section"
    section.textContent = "Ingredients"
    wrap.appendChild(section)

    if (ingredients.length > 0) {
      const list = document.createElement("ul")
      list.className = "voice-recipe-card__list voice-recipe-card__list--ingredients"
      ingredients.forEach((ing) => {
        const li = document.createElement("li")
        li.textContent = ing.toString()
        list.appendChild(li)
      })
      wrap.appendChild(list)
    } else {
      const hint = document.createElement("p")
      hint.className = "voice-recipe-card__empty-hint"
      hint.textContent = "Ingredients will appear here when available — ask aloud for details."
      wrap.appendChild(hint)
    }

    return wrap
  }

  buildRecipeStepsContent(recipe) {
    const wrap = document.createElement("div")
    wrap.className = "voice-recipe-card__slide-inner"

    const heading = document.createElement("div")
    heading.className = "voice-recipe-card__section"
    heading.textContent = "Guiding steps"
    wrap.appendChild(heading)

    const steps = Array.isArray(recipe.steps_preview) ? recipe.steps_preview : []
    if (steps.length > 0) {
      const list = document.createElement("ol")
      list.className = "voice-recipe-card__list voice-recipe-card__steps voice-recipe-card__steps--fancy"
      steps.forEach((step) => {
        const li = document.createElement("li")
        li.textContent = step.toString()
        list.appendChild(li)
      })
      wrap.appendChild(list)
    } else {
      const hint = document.createElement("p")
      hint.className = "voice-recipe-card__empty-hint"
      hint.textContent = "I can guide you through the steps by voice — use “show the recipe” or ask me to walk through it."
      wrap.appendChild(hint)
    }

    return wrap
  }

  goToRecipeSlide(index) {
    if (!this.recipeSliderRefs) return
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
    const refs = this.recipeSliderRefs
    if (!refs) return

    const { track, indicator, prevBtn, nextBtn } = refs
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
