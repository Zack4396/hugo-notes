---
title: {{ replace .TranslationBaseName "-" " " | title }}
linkTitle: {{ replace .TranslationBaseName "-" " " | title }}
date: {{ .Date }}
type: posts
draft: false
categories:
collections:
tags:
password: {{ substr .File.UniqueID 0 7 }}
resources:
  - name: featured-image
    # https://coverview.lruihao.cn/editor
    # sudo apt-get install webp
    # cwebp cover.png -o cover.webp
    src: cover.webp

---

<!--more-->
