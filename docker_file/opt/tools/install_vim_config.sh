#!/bin/bash
cd ~
git clone https://github.com/machsix/vimrc.git vimrc
cd vimrc
git submodule update --init --recursive
cd ~
mv vimrc/.vim ./
mv vimrc/.vimrc ./
vim -c 'PlugInstall' -c 'qa!'