(org.shirakumo.fraf.trial.release:configure
  :build (:features (:kandria-release)
          :prune ("pool/effects/"
                  "pool/workbench/"
                  "pool/trial/"
                  "pool/kandria/music/"
                  "pool/kandria/sound/"
                  "pool/kandria/*/*.ase"
                  "pool/music/*.wav"
                  "pool/**/*.*~"
                  "pool/**/*.kra"
                  "pool/**/#*#")
          :copy ("CHANGES.mess" "README.mess"
                                ("bin/pool/trial/fps-texture.png"
                                 "pool/trial/fps-texture.png")))
  :itch (:user "Shinmera")
  :steam (:branch "developer"
          :user "shirakumo_org")
  :upload (:targets #(:steam))
  :system "kandria")
