(org.shirakumo.fraf.trial.release:configure
  :build (:features (:kandria-release)
          :prune ("pool/effects/"
                  "pool/workbench/"
                  "pool/trial/"
                  "pool/kandria/music/"
                  "pool/kandria/sound/"
                  "pool/kandria/*/*.ase"
                  "pool/music/*.wav"
                  "mods/*/"
                  "mods/*.zip"
                  "pool/**/*.*~"
                  "pool/**/*.kra"
                  "pool/**/#*#")
          :copy ("CHANGES.mess" "README.mess"
                                ("bin/pool/trial/fps-texture.png"
                                 "pool/trial/fps-texture.png")))
  :depots (:linux ("*.so" "kandria-linux.run")
           :windows ("*.dll" "kandria-windows.exe")
           :macos ("*.dylib" "kandria-macos.o")
           :content ("pool/" "mods/" "lang/" "world.zip" "CHANGES.mess" "README.mess" "keymap.lisp"))
  :bundles (:linux (:depots (:linux :content))
            :windows (:depots (:windows :content))
            :macos (:depots (:macos :content))
            :all (:depots (:linux :windows :macos :content)))
  :keygen (:key "333B5B5C-9DDC-4E41-9C82-F2254330722E"
           :secret "DCBE2959-5231-4D22-85BF-F12A9C4781D1"
           :api-base "https://keygen.tymoon.eu/api/"
           :secrets "keygen.tymoon.eu"
           :bundles (:linux 3
                     :windows 2))
  :itch (:user "Shinmera"
         :bundles (:linux "kandria:linux-64"
                   :windows "kandria:windows-64"))
  :steam (:branch "developer"
          :user "shirakumo_org")
  :upload (:targets #(:steam))
  :bundle (:targets #(:windows :linux))
  :system "kandria")
