# explainer: checks plain `claude` will use the Pro subscription, not quietly bill an API key

function cc-check --description "Check which Claude Code lane your shell is set up for"
    set -l problem 0

    if set -q ANTHROPIC_API_KEY; and test -n "$ANTHROPIC_API_KEY"
        echo "WARNING  ANTHROPIC_API_KEY is set."
        echo "         Claude Code will use pay-per-token API billing and your"
        echo "         Pro subscription will sit unused. Unset it to use Pro."
        set problem 1
    else
        echo "ok       ANTHROPIC_API_KEY is unset — Pro subscription will be used."
    end

    if set -q ANTHROPIC_BASE_URL; and test -n "$ANTHROPIC_BASE_URL"
        echo "WARNING  ANTHROPIC_BASE_URL is set to: $ANTHROPIC_BASE_URL"
        echo "         the claude command is being redirected away from Anthropic."
        set problem 1
    else
        echo "ok       ANTHROPIC_BASE_URL is unset — going direct to Anthropic."
    end

    echo ""
    if test $problem -eq 0
        echo "  claude     → Claude Pro (primary)"
    end
    echo "  cc-local   → local Ollama (fallback)"
end
