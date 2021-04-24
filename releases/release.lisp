(org.shirakumo.fraf.trial.release:configure
  :build (:features (:kandria-release)
          :prune ("pool/EFFECTS/"
                  "pool/WORKBENCH/"
                  "pool/TRIAL/"
                  "pool/KANDRIA/*.ase")
          :copy ("CHANGES.mess" "README.mess"))
  :itch (:user "Shinmera")
  :steam (:branch "developer"
          :user "shirakumo_org")
  :system "kandria")
