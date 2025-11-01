# Formulyx

A **Highly extensible formulation chemistry software tool**  written in **Common Lisp**.

**WIP:** Project is in the very early development stages...

<p align="center">
  <img src="assets/common-lisp.svg" width="200" />
</p>

---

Create an Advanced Formulation Chemistry Software Tool for the creation of
Formulas, Specifications, Raw Materials, and Regulatory data.

## Goals

I've decided to first start out by building simple tools needed for formulation,
such as the calculation of Hydrophilic-Lipophilic Balance/Deviation, create a simple
UI, then slowly add on more advanced features like a formula builder, regulatory
intelligence, and AI assistance..

- [ ] Implement HLB & HLD calculation backend
- [ ] Scaffold initial database for surfactants/oils 
- [ ] Build unit test framework
- [ ] Build documentation system
- [ ] Build out initial UI (`cl-electron`)
- [ ] Executable creation

---

## Installation

```bash
  # Clone the repo
  $ git clone https://github.com/logoraz/formulyx.git
  $ cd formulyx
  # Load in your Lisp REPL (SBCL only for now)
  $ sbcl
```

```lisp
  ;; Load system
  (asdf:load-system :formulyx)

  ;; Test system
  (asdf:test-system :formulyx)

```

## References

- [ ] https://github.com/atlas-engineer/cl-electron
- [ ] TBD
- [ ] TBD