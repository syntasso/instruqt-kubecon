---
slug: complete-environment
id: rfag6nho4em2
type: challenge
title: Complete environment
teaser: A chance to explore freely
notes:
- type: text
  contents: "# A true playground \U0001F6DD\n\nSo far, this course has focused on
    a specific implementation to cover all the key parts of the hackathon setup.\n\nThis
    includes:\n* Creating platform APIs using community Promises\n* Using resources
    provided by Platform APIs\n* Customising APIs to business-specific requirements\n*
    Providing a Backstage portal as a user-friendly interface\n* Managing resources
    during and after the hackathon as a fleet\n\nThis next section is not guided.
    It is just the environment, fully set up from the previous work and ready to be
    explored. Feel free to spend as little or as much time as you want here, but remember,
    customisations only live for the duration of a single session, and upon return,
    the environment will start fresh again."
tabs:
- id: quizkgck2nx6
  title: terminal
  type: terminal
  hostname: docker-vm
- id: passevfozhua
  title: Editor
  type: code
  hostname: docker-vm
  path: /root/hackathon
- id: ccv3xro1zg9q
  title: Gitea
  type: service
  hostname: docker-vm
  path: /gitea_admin
  port: 31443
- id: sncdffhsd5ny
  title: Backstage
  type: service
  hostname: docker-vm
  path: /
  port: 31340
- id: hagw5al9ikwf
  title: Example App UI
  type: service
  hostname: docker-vm
  path: /
  port: 80
difficulty: basic
timelimit: 1800
enhanced_loading: null
---

This part of the workshop is free play.

The current state for this hackathon is as follows:

![final-ux](../assets/final-ux.png)

And users experience this:

![first-request-ux](../assets/first-request-ux.png)


⏭️ Next steps
===

You now have all the tools necessary to provide a fast-paced hackathon at your own organisation while not sacrificing safety or efficiency.

Feel free to return to this course on Instruqt at any time, and this is free to share!
https://play.instruqt.com/syntasso-kubecon/invite/nwwxla8dwjnd

Finally, if you are interested in how this course was designed, or want access to any of the tools provided in this VM, check out the code used:
https://github.com/syntasso/instruqt-kubecon/tree/main/hackathon


🙏 Feedback, please!
===

Thank you for spending your time with us. We don't take that lightly and would love to hear how to make the next session even better!

Please share any feedback directly with [Phill](https://www.linkedin.com/in/phillip-morton/) and [Abby](https://www.linkedin.com/in/abbybangser/) as well as via the CNCF Schedule page.

In addition, take advantage of your time at KubeCon to stop by the booths for each of the projects used today:
* [Backstage](https://backstage.io/): Project Pavilion
* [Kratix](https://kratix.io/): S641
* [FluxCD](https://fluxcd.io/): Project Pavilion
* [Minio](https://min.io/): N280
* [Gitea](http://gitea.com/): Not here, but check the website out!
* [Instruqt](https://instruqt.com/): Roaming about!
