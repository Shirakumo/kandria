(org.shirakumo.fraf.trial.release:configure
  :build (:features (:kandria-release :kandria-demo)
          :prune ("pool/effects/"
                  "pool/workbench/"
                  "pool/trial/"
                  "pool/kandria/music/"
                  "pool/kandria/sound/"
                  "pool/kandria/*/*.ase"
                  "pool/music/*.wav"
                  "pool/**/*.*~")
          :copy ("CHANGES.mess" "CREDITS.mess" "README.mess"))
  :itch (:user "Shinmera"
         :project "kandria")
  :steam (:branch "developer"
          :user "shirakumo_org")
  :system "kandria")
