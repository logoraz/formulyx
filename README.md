# Formulyx - Advanced Formulation Chemistry Tool.

<p align="center">
  <img src="assets/logoraz-symbol.svg" width="200" />
  <img src="assets/yin-yang-lisp-logo_512_svg.png" width="100" />
</p>

Create an Advanced Formulation Chemistry Software Tool for the creation of
Formulas, Specifications, Raw Materials, and Regulatory data. This project
is a work in progress and is in very early stages.

## Build

Currently, the setup of this project itself acts as a template on how to scaffold
a modern Common Lisp system (declarative style) along with a testing framework.
The Common Lisp code written herein also acts as a 'style guide' on my
functionality/aesthetic preferences. I also use
[ocicl](https://github.com/ocicl/ocicl) for a modern approach for Common Lisp
Systems Management, its a great tool - the only one that has a CLI to tie into a
unix/linux workflow.

The most recent addition is a testing framework (FiveAM) that has an example test
template borrowed from 
[The Common Lisp Cookbook:Testing With FiveAM](https://lispcookbook.github.io/cl-cookbook/testing.html#testing-with-fiveam).


### Build, Test, Create Executable, and Generate Documentation:

```lisp
;; Build System
;; will need `cl-gtk4` library manually injected in /ocicl/
;; see below section Play & Learn:ADW/GTK4 Example
(asdf:load-system :formulyx)

;; Test System
(asdf:test-system :formulyx/test)

;; Create Executable
(asdf:make :formulyx/executable)

;; Generate Documentation
(asdf:load-system :formulyx/docs)

;; Build Libraries (Extensions)
(asdf:load-system :formulyx/libraries)

```


### Hack

As an initial test of the system scaffold, I've implemented the `SDRAW` tool:

```lisp
;; Load Library Systems
(asdf:load-system :formulyx/libraries)

;; Enter into cl-mexp/sdraw package
(in-package :cl-chemexp/sdraw)

(sdraw '(This (is a (test!))))
;; =>
;; [*|*]--->[*|*]--->NIL
;;  |        |
;;  v        v
;; THIS     [*|*]--->[*|*]--->[*|*]--->NIL
;;           |        |        |
;;           v        v        v
;;           IS       A       [*|*]--->NIL
;;                             |
;;                             v
;;                            TEST!

```


#### ADW/GTK4 Example

Currently working on establishing a gtk4/adw frontend using `cl-gtk4`.
You can test it as follows. See: https://github.com/bohonghuang/cl-gtk4

Note: ocicl will install most of the dependencies, however, currently `cl-gtk4`
is not pulling/available and so `cl-gtk4` will need to be mainly placed in
the created `/ocicl/` directory:

```shell
  $ cd ./ocicl/
  $ git clone https://github.com/bohonghuang/cl-gtk4.git
```

Then you can run the adw tutorial package as follows:

```lisp
(asdf:load-system :formulyx)
(in-package :frontends/adw-gtk4)
(main)
```


## Roadmap

 - [ ] Build a documentation system 
 - [ ] Build database for Formulas, Raw Materials, and Regulatory Data
 - [ ] Start adding unit testing
 - [ ] Build a ADW/GTK4 frontend.


## References:
 - Frontend Development
   - https://github.com/bohonghuang/cl-gtk4
   - https://github.com/andy128k/cl-gobject-introspection
 - Database
   - 

