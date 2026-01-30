#! /usr/bin/env fish

set lines ""
for entry in (jq -r '.en.[]' untranslated.txt)
    set lines "$lines$entry : $(jq -r ".$entry" lib/l10n/app_zh.arb)"\n
end

set lines $lines"Untranslate the above entries into English, don't change the format"

echo (echo $lines | count) entries untranslated

if test (echo $lines | count) -ne 0
    echo $lines | qwen
end
