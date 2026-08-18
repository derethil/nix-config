{self, ...}: {
  flake.modules.homeManager.hammerspoon-messages = {
    imports = [self.modules.generic.hammerspoon-options];

    hammerspoon.scripts = [
      /*
      lua
      */
      ''
        local messagesSavedState = os.getenv("HOME")
          .. "/Library/Saved Application State/com.apple.iChat.savedState"

        local messagesQuitWatcher = hs.application.watcher.new(function(appName, event)
          if appName == "Messages" and event == hs.application.watcher.terminated then
            os.execute('rm -rf "' .. messagesSavedState .. '"')
            os.execute("defaults delete com.apple.iChat")
          end
        end)

        messagesQuitWatcher:start()
      ''
    ];
  };
}
