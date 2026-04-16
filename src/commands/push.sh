#!/bin/bash

if toolboxd.arggt "1" ; then
    wgit.push "$1"
else
    wgit.push "$branch"
fi