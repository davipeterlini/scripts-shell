tell application iTerm2
    create profile with name 'test'
    tell current session of current window
        set profile to "test"
    end tell
end tell