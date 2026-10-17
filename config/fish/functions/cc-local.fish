# explainer: Claude Code on local Ollama for when the Pro limit runs out, plain `claude` stays on Pro
# explainer: other model for one call: set -x CC_LOCAL_MODEL qwen2.5-coder:7b

function cc-local --description "Claude Code on local Ollama (does not use Claude Pro quota)"
    if not curl -sf --max-time 2 http://localhost:11434/api/version >/dev/null 2>&1
        echo "Ollama is not responding on :11434"
        echo "Start it with:  sudo systemctl start ollama"
        return 1
    end

    set -l model $CC_LOCAL_MODEL
    test -n "$model"; or set model gpt-oss:20b

    if not ollama list 2>/dev/null | string match -q -- "$model*"
        echo "Model '$model' is not pulled. Available:"
        ollama list
        echo ""
        echo "Pull it with:  ollama pull $model"
        return 1
    end

    echo "── Claude Code · LOCAL model: $model ─────────────"
    echo "   Claude Pro quota is NOT being used."
    echo ""

    # decision: env scoped to this one call. the last four stop update checks, telemetry and crash reports, which go out whatever the model
    env ANTHROPIC_BASE_URL="http://localhost:11434" \
        ANTHROPIC_AUTH_TOKEN="ollama" \
        ANTHROPIC_API_KEY="" \
        ANTHROPIC_MODEL="$model" \
        ANTHROPIC_SMALL_FAST_MODEL="$model" \
        ANTHROPIC_DEFAULT_SONNET_MODEL="$model" \
        ANTHROPIC_DEFAULT_OPUS_MODEL="$model" \
        ANTHROPIC_DEFAULT_HAIKU_MODEL="$model" \
        CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1 \
        DISABLE_TELEMETRY=1 \
        DISABLE_ERROR_REPORTING=1 \
        DISABLE_AUTOUPDATER=1 \
        claude $argv
end
