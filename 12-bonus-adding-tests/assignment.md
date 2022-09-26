---
slug: bonus-adding-tests
id: il5zy8dwddln
type: challenge
title: 'Bonus: Adding tests'
teaser: Kubebuilder doesn't just scaffold your operator code, it also prepares test code as well.
notes:
- type: text
  contents: |-
    Right now the operator is fairly simple, but you can see how even the error handling logic can get complex.
    
    Explore how kubebuilder sets you up for success with a testing framework as well.

    In this section you will:
    * Write a unit test for your operator
    * Run your test using make targets
tabs:
- title: K8s Shell
  type: terminal
  hostname: kubernetes-vm
  workdir: /root/demo
- title: Run Shell
  type: terminal
  hostname: kubernetes-vm
  workdir: /root/demo
- title: Code editor
  type: service
  hostname: kubernetes-vm
  path: /
  port: 8443
- title: Website
  type: service
  hostname: kubernetes-vm
  path: /
  port: 31000
difficulty: basic
timelimit: 600
---

🤖 Run current test suite
==============

make test

👩🏾‍💻 Write a basic test
==============

something about catching errors?

make test

📕 Summary
==============

Discuss need for integration level tests
