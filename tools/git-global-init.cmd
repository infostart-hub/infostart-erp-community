@chcp 65001

@rem for current user

git config --global user.name "Artur Ayukhanov"
git config --global user.email aartbear@gmail.com

@rem global

git config --global core.quotePath false

@rem for Windows

git config --global core.autocrlf true
git config --global core.safecrlf true

@rem for Linux and MacOS
@rem git config --global core.autocrlf input
@rem git config --global core.safecrlf true

git config --global http.postBuffer 1048576000

@echo
@echo do it only for administrator mode

@rem git config --system core.longpaths true
@rem SET LC_ALL=C.UTF-8
