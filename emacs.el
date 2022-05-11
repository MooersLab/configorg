;; Start the emacs-client server

;; (server-start)

;;
(require 'package)

(defmacro append-to-list (target suffix)
  "Append SUFFIX to TARGET in place."
  `(setq ,target (append ,target ,suffix)))

(append-to-list package-archives
                '(("melpa" . "http://melpa.org/packages/") ;; Main package archive
                  ("melpa-stable" . "http://stable.melpa.org/packages/") ;; Some packages might only do stable releases?
                 )) 

(package-initialize)

;; Ensure use-package is present. From here on out, all packages are loaded
;; with use-package. Also, refresh the package archive on load so we can pull the latest packages.
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(use-package exec-path-from-shell
  :config
  (exec-path-from-shell-initialize))

;; Allow navigation between use-package stanzas with imenu.
;; This has to be set before loading use-package.
(defvar use-package-enable-imenu-support t)
(require 'use-package)
(setq
 use-package-always-ensure t ;; Makes sure to download new packages if they aren't already downloaded
 use-package-verbose t) ;; Package install logging. Packages break, nice to know why.

;; Any Customize-based settings should live in custom.el, not here.
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file 'noerror)

;;(use-package doom-themes
;;  :init
;;  (load-theme 'doom-one))


(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enabqle-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  ;;(load-theme 'doom-one t)
  (load-theme 'doom-flatwhite t)
  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))




;;; OS specific config
(defconst *is-a-mac* (eq system-type 'darwin))
(defconst *is-a-linux* (eq system-type 'gnu/linux))

;; Emacs feels like it's developed with linux in mind, here are some mac UX improvements
;;(when *is-a-mac*
;;   (setq mac-command-modifier 'meta)
;;   (setq mac-option-modifier 'none)
;;   (setq default-input-method "MacOSX"))

;; Some linux love, too
;;(when *is-a-linux*
;;  (setq x-super-keysym 'meta))

;; Fullscreen by default, as early as possible. This tiny window is not enough
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Make M-x and other mini-buffers sortable, filterable
(use-package ivy
  :init
  (ivy-mode 1)
  (global-set-key "\C-s" 'swiper)
  (unbind-key "S-SPC" ivy-minibuffer-map)
  (setq ivy-height 15
        ivy-use-virtual-buffers t
        ivy-use-selectable-prompt t))

(use-package ivy-bibtex)

(use-package counsel
  :after ivy
  :init
  (counsel-mode 1)
  :bind (:map ivy-minibuffer-map))

;; Company is the best Emacs completion system.
(use-package company
  :bind (("C-." . company-complete))
  :custom
  (company-idle-delay 0) ;; I always want completion, give it to me asap
  (company-dabbrev-downcase nil "Don't downcase returned candidates.")
  (company-show-numbers t "Numbers are helpful.")
  (company-tooltip-limit 10 "The more the merrier.")
  :config
  (global-company-mode) ;; We want completion everywhere

  ;; use numbers 0-9 to select company completion candidates
  (let ((map company-active-map))
    (mapc (lambda (x) (define-key map (format "%d" x)
                        `(lambda () (interactive) (company-complete-number ,x))))
          (number-sequence 0 9))))

;; source: https://stackoverflow.com/questions/19142142/auto-complete-mode-not-working
(add-hook 'c++-mode-hook
      (lambda()
            (semantic-mode 1)
            (define-key c++-mode-map (kbd "C-z") 'c++-auto-complete)))

(defun c++-auto-complete ()
  (interactive)
  (let ((ac-sources
         `(ac-source-semantic
           ,@ac-sources)))
  (auto-complete)))





;; Flycheck is the newer version of flymake and is needed to make lsp-mode not freak out.
(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode t)
  :config
  (add-hook 'prog-mode-hook 'flycheck-mode) ;; always lint my code
  (add-hook 'after-init-hook #'global-flycheck-mode))
(add-hook 'find-file-hooks 'turn-on-flyspell) ;; Turn on for all files.

(autoload 'flycheck "flycheck" "" t)
(flycheck-define-checker textlint
  "A linter for textlint."
  :command ("npx" "textlint"
            "--config" "/Users/blaine/.emacs.d/.textlintrc"
            "--format" "unix"
            "--rule" "write-good"
            "--rule" "no-start-duplicated-conjunction"
            "--rule" "max-comma"
            "--rule" "terminology"
            "--rule" "period-in-list-item"
            "--rule" "abbr-within-parentheses"
            "--rule" "alex"
            "--rule" "common-misspellings"
            "--rule" "en-max-word-count"
            "--rule" "diacritics"
            "--rule" "stop-words"
            "--plugin"
            (eval
             (if (derived-mode-p 'tex-mode)
                 "latex"
               "@textlint/text"))
            source-inplace)
  :error-patterns
  ((warning line-start (file-name) ":" line ":" column ": "
            (message (one-or-more not-newline)
                     (zero-or-more "\n" (any " ") (one-or-more not-newline)))
            line-end))
  :modes (text-mode latex-mode org-mode markdown-mode)
  )
(add-to-list 'flycheck-checkers 'textlint)



(use-package lsp-mode
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         (latex-mode . lsp)
         ;; if you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)

;; optionally
;; (use-package lsp-ui :commands lsp-ui-mode)
;; if you are helm user
;; (use-package helm-lsp :commands helm-lsp-workspace-symbol)
;; if you are ivy user
(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

;; optionally if you want to use debugger
;; (use-package dap-mode)
;; (use-package dap-LANGUAGE) to load the dap adapter for your language

;; optional if you want which-key integration
;; (use-package which-key
;;     :config
;;     (which-key-mode))
;; 
;; Old version
;; ;; Package for interacting with language servers
;; (use-package lsp-mode
;;   :commands lsp
;;   :hook
;;   (sh-mode . lsp) 
;;   :config  
;;   (setq lsp-prefer-flymake nil ;; Flymake is outdated
;;         lsp-headerline-breadcrumb-mode nil)) ;; I don't like the symbols on the header a-la-vscode, remove this if you like them.

;; Basic python configuration
(use-package python
  :init
  (require 'python)
  :config
  ;; As soon as we detect python go look for that virtual env.
  (add-hook 'python-mode-hook #'auto-virtualenv-set-virtualenv))

;; Pyenv is the only reasonable way to manage python installs. What a mess.
(use-package pyvenv)

;; Auto detect my virtual env, please
(use-package auto-virtualenv)

;; Use the microsoft-python language server, it's the best available as of writing this
(use-package lsp-python-ms
  :hook (python-mode . (lambda ()
                          (require 'lsp-python-ms)
                          (lsp))))  ; or lsp-deferred

;; We need something to manage the various projects we work on
;; and for common functionality like project-wide searching, fuzzy file finding etc.
;; Use C-x p f to add a file to a project.
(use-package projectile
  :init
  (projectile-mode t) ;; Enable this immediately
  :config
  (define-key projectile-mode-map (kbd "C-x p") 'projectile-command-map)
  (setq projectile-enable-caching t ;; Much better performance on large projects
        projectile-completion-system 'ivy)) ;; Ideally the minibuffer should aways look similar

;; Counsel and projectile should work together.
(use-package counsel-projectile
  :init
  (counsel-projectile-mode))

;; This is the best git client ever.
;; I know some people who only use emacs for magit (i.e dev in IntelliJ and commit/rebase/diff in emacs)
;; it's that good.
(use-package magit
  :config
  (magit-auto-revert-mode t) ;; Buffers will reload automatically if for example you hard-reset/revert changes in magit
  (setq magit-completing-read-function 'ivy-completing-read)) ;; Everything should work with Ivy
      
;; replace C-x o with M-o
(global-set-key (kbd "M-o") 'other-window)

;; this setting lets you move between windows cardinally with shift-arrows 
(windmove-default-keybindings)

;;;; Begin improvements
;;
;;;; The best package for managing opened files that I've ever used.
;;;; No more tabbing through 10 open files, and no more counting your open files to Cmd-num to.
;;(use-package ace-window
;;  :bind
;;  ("M-o" . ace-window)
;;  :config
;;  (set-face-attribute 'aw-leading-char-face nil
;;                      :foreground "deep sky blue"
;;                      :weight 'bold
;;                      :height 2.0) ;; Some nice formatting to make the letters more visible
;;  (setq aw-scope 'frame)
;;  (setq aw-dispatch-always t)
;;  (setq aw-keys '(?q ?w ?e ?r ?a ?s ?d ?f))
;;  (setq aw-dispatch-alist '((?c aw-swap-window "Ace - Swap Window")
;;                            (?n aw-flip-window)))
;;  (ace-window-display-mode t))

;; Sort M-x by recently used, I can't believe this isn't a default already.
(use-package smex)

;; Begin evil config

;; Optional for vim users
;;(use-package evil
;;  :init
;;  (evil-mode t))


;;;;;;;;;;;;;;;; My settings

;; https://github.com/purcell/exec-path-from-shell
(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))


;; Common settings
;; Do not end sentences with more than one whitespace.
(setq sentence-end-double-space nil)
;; Display line numbers
(when (version<= "26.0.50" emacs-version)
  (global-display-line-numbers-mode))

  ;; not GUI tool bar
  (tool-bar-mode 0) 

  ;; display time on model line
  (display-time-mode t)

;; set PATHS
(use-package exec-path-from-shell
  :init
  (setenv "SHELL" "/bin/zsh")
  :ensure t
  :if (memq window-system '(mac ns x))
  :config
  (setq exec-path-from-shell-variables '("PATH" "GOPATH"))
  (exec-path-from-shell-initialize))

;; https://github.com/manateelazycat/awesome-tab
(use-package awesome-tab
  :load-path "~/Dropbox/softwareDropBox/elisp/awesome-tab"
  :config
  (awesome-tab-mode t))


;; dashboard
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook))

(setq dashboard-center-content t)
(setq dashboard-insert-ascii-banner-centered t)
(setq dashboard-banner-logo-title "Loxo or selpercatinib. FDA approved inhibitor for lung caner in 2020.")
(use-package all-the-icons)
(insert (all-the-icons-icon-for-buffer))
(setq dashboard-center-content t)
(setq dashboard-image-banner-max-width 222)
(setq dashboard-image-banner-max-height 169)
(use-package page-break-lines)
(setq dashboard-set-heading-icons t)
(setq dashboard-set-file-icons t)
(setq dashboard-startup-banner "/Users/blaine/images/loxo.png")
(setq dashboard-items '((recents  . 12)
                        (bookmarks . 25)
                        (projects . 20)
                        (agenda . 15)
                        (registers . 5)))
;; Set the title
;;(setq dashboard-banner-logo-title "Dashboard of Blaine Mooers")
;; Set the banner
;;(setq dashboard-startup-banner 'official)
;;(setq dashboard-startup-banner "/Users/blaine/Images/jmjd4alphaFOld1Aug30.png")
;; Value can be
;; 'official which displays the official emacs logo
;; 'logo which displays an alternative emacs logo
;; 1, 2 or 3 which displays one of the text banners
;; "path/to/your/image.gif", "path/to/your/image.png" or "path/to/your/text.txt" which displays whatever gif/image/text you would prefer

;; Content is not centered by default. To center, set
;;(setq dashboard-center-content t)

;; To disable shortcut "jump" indicators for each section, set
(setq dashboard-show-shortcuts nil)

; To show info about the packages loaded and the init time:
(setq dashboard-set-init-info t)

; To use it with counsel-projectile or persp-projectile
(setq dashboard-projects-switch-function 'projectile-persp-switch-project)

; To display today’s agenda items on the dashboard, add agenda to dashboard-items:
(add-to-list 'dashboard-items '(agenda) t)

;To show agenda for the upcoming seven days set the variable dashboard-week-agenda to t.
(setq dashboard-week-agenda t)




;; (load-theme 'leuven t)

;; (use-package tommyh-theme
;;   :config
;;   (load-theme 'tommyh t))


;; use org mode
(use-package org)

;;
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)

;; org-capture
(define-key global-map "\C-cc" 'org-capture)
(global-set-key (kbd "<f6>") 'org-capture)
(define-key global-map "\C-cl" 'org-store-link)
;; Total word count for a org file and word count by headline.
(define-key global-map "\C-cw" 'org-wc-display)
;; Open a fileset in separate windows.
(define-key global-map "\C-cfo" 'filesets-open)
;; Open a fileset in separate windows.
(define-key global-map "\C-cfc" 'filesets-close)


;;  ;; word count
;;  (defun my-latex-setup ()
;;  defun latex-word-count ()
;;   (interactive)
;;   (let* ((this-file (buffer-file-name))
;;       (word-count
;;        (with-output-to-string
;;          (with-current-buffer standard-output
;;            (call-process "/usr/local/bin/texcount.pl" nil t nil "-brief" this-file)))))
;;  (string-match "\n$" word-count)
;;  (message (replace-match "" nil nil word-count))))
;;  (define-key LaTeX-mode-map "\C-cw" 'latex-word-count))
;;  (add-hook 'LaTeX-mode-hook 'my-latex-setup t)
;;  
;;  ;; Fold and unfold sectin with C-tab
;;  (add-hook 'LaTeX-mode-hook 'outline-minor-mode)
;;  ;;(define-key LaTeX-mode-map (kbd "<C-tab>") 'outline-toggle-children)


;; Using M and C keys to fold. https://www.emacswiki.org/emacs/OutlineMinorMode
(global-set-key [M-left] 'outline-hide-body)
(global-set-key [M-right] 'outline-show-subtree)
(global-set-key [M-up] 'outline-previous-heading)
(global-set-key [M-down] 'outline-next-heading)
(global-set-key [C-M-left] 'outline-hide-sublevels)
(global-set-key [C-M-right] 'outline-show-children)
(global-set-key [C-M-up] 'outline-previous-visible-heading)
(global-set-key [C-M-down] 'outline-next-visible-heading)




(use-package dropbox)
(use-package oauth)
(use-package json)



;; ;; LaTeX grammar checker via language tool.
;; ;; https://github.com/emacs-languagetool/lsp-ltex
;; (use-package lsp-latex
;; ensure t
;; hook (text-mode . (lambda ()
;;                  (require 'lsp-latex)
;;                  (lsp))))  ; or lsp-deferred

(use-package writegood-mode)
(global-set-key "\C-cg" 'writegood-mode)


;; emacs-grammarly 
;; https://github.com/emacs-grammarly/send-to-osx-grammarly
;; grammarly.app and new file msut be open
;; load el file in your .emacs, e.g.
;;;; (load-file "~/.emacs.d/plugins/send-to-osx-grammarly/send-to-osx-grammarly.el")
;;;; (call-process-shell-command "osascript ~/.emacs.d/plugins/send-to-osx-grammarly/pull.scpt")
;;;; (define-key global-map (kbd "C-c C-g h") #'send-to-osx-grammarly-push)
;;;; (define-key global-map (kbd "C-c C-g l") #'send-to-osx-grammarly-pull)
;;;; ;;
;;;; (require 'keytar)
;;;; ;;(message "%s" (keytar-get-password "vscode-grammarly-cookie" "default"))
;;;; 
;;;; ;; https://github.com/emacs-grammarly/lsp-grammarly
;;;; (use-package lsp-grammarly
;;;;   :ensure t
;;;;   :hook (text-mode . (lambda ()
;;;;                        (require 'lsp-grammarly)
;;;;                        (lsp))))  ; or lsp-deferred
;;;; (setq lsp-grammarly-auto-activate t)
;;;; 
;;;; (require 'grammarly)
;;;; 
;;;; (defun test-on-message (data)
;;;;   "On message callback with DATA."
;;;;   (message "[DATA] %s" data))
;;;; 
;;;; ;; Set callback for receiving data.
;;;; (add-to-list 'grammarly-on-message-function-list 'test-on-message)
;;;; 
;;;; ;; Send check text request.
;;;; (grammarly-check-text "Hello World")
;;;; 
;;;; (setq grammarly-username "bmooers1@gmail.com")  ; Your Grammarly Username
;;;; (setq grammarly-password "**********")  ; Your Grammarly Password

;; https://github.com/emacs-grammarly
;(require 'flycheck-grammarly)	     
;(add-hook 'text-mode-hook 'flymake-grammarly-load)
;(add-hook 'latex-mode-hook 'flymake-grammarly-load)
;(add-hook 'org-mode-hook 'flymake-grammarly-load)
;(add-hook 'markdown-mode-hook 'flymake-grammarly-load)

(use-package keytar)

;; Source https://bpa.st/ST3Q
;;  ;; Show and hide blocks in 
;;  (defun my/org-show-blocks (arg)
;;  "Show all blocks in the current subtree.
;;  
;;  With prefix argument, show all blocks in the current buffer."
;;  (interactive "p")
;;  (if (eq arg 4)
;;      (org-show-all '(blocks))
;;    (save-restriction
;;      (org-narrow-to-subtree)
;;      (org-show-all '(blocks)))))
;;  
;;  (define-key org-mode-map (kbd "C-c s b") 'my/org-show-blocks)
;;  
;;  (defun my/org-hide-blocks (arg)
;;    "Fold all blocks in the current subtree.
;;  
;;  With prefix argument, fold all blocks in the current buffer."
;;  (interactive "p")
;;  (if (eq arg 4)
;;      (org-hide-block-all)
;;    (save-restriction
;;      (org-narrow-to-subtree)
;;      (org-hide-block-all))))
;;  
;;  (define-key org-mode-map (kbd "C-c h b") 'my/org-hide-blocks)

;; 
;; ;; org-bullets
;; (use-package org-bullets
;; after org
;; hook (org-mode . org-bullets-mode)
;; custom
;; org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))
;;
;; https://github.com/sabof/org-bullets
(require 'org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))


;; org-journal
(use-package org-journal)
(setq org-journal-dir="~/gtd/journal")

;; org-latex minted

(add-to-list 'org-latex-packages-alist '("" "minted"))
(setq org-latex-listings 'minted)

(setq org-latex-minted-options
  '(("frame" "lines") ("linenos=false") ("framerule=2pt") ("breaklines")))
(setq org-latex-pdf-process
'("pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
  "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
  "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"))
(setq org-src-fontify-natively t)



;; org pomodoro
(use-package org-pomodoro
 :ensure t
 :commands (org-pomodoro)
 :config
 (setq alert-user-configuration (quote ((((:category . "org-pomodoro")) libnotify nil)))))

(use-package sound-wav)
(setq org-pomodoro-ticking-sound-p 1)
; (setq org-pomodoro-ticking-sound-states '(:pomodoro :short-break :long-break))
(setq org-pomodoro-ticking-sound-states '(:pomodoro))
(setq org-pomodoro-ticking-frequency 1)
(setq org-pomodoro-audio-player "mplayer")
(setq org-pomodoro-finished-sound-args "-volume 0.9")
(setq org-pomodoro-long-break-sound-args "-volume 0.9")
(setq org-pomodoro-short-break-sound-args "-volume 0.9")
(setq org-pomodoro-ticking-sound-args "-volume 0.3")

(global-set-key (kbd "C-c o") 'org-pomodoro)

;; org-ref
(use-package org-ref)

(setq bibtex-completion-bibliography '("~/Dropbox/global.bib")
	bibtex-completion-library-path '("/Users/blaine/Dropbox/RNAdrugComplexCrystallizationPDFs/")
	bibtex-completion-notes-path "~/bibliography/notes/"
	bibtex-completion-notes-template-multiple-files "* ${author-or-editor}, ${title}, ${journal}, (${year}) :${=type=}: \n\nSee [[cite:&${=key=}]]\n"

	bibtex-completion-additional-search-fields '(keywords)
	bibtex-completion-display-formats
	'((article       . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${journal:40}")
	  (inbook        . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} Chapter ${chapter:32}")
	  (incollection  . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${booktitle:40}")
	  (inproceedings . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${booktitle:40}")
	  (t             . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*}"))
	bibtex-completion-pdf-open-function
	(lambda (fpath)
	  (call-process "open" nil 0 nil fpath)))

(use-package bibtex)

(setq bibtex-autokey-year-length 4
	bibtex-autokey-name-year-separator "-"
	bibtex-autokey-year-title-separator "-"
	bibtex-autokey-titleword-separator "-"
	bibtex-autokey-titlewords 2
	bibtex-autokey-titlewords-stretch 1
	bibtex-autokey-titleword-length 5
	org-ref-bibtex-hydra-key-binding (kbd "H-b"))

(define-key bibtex-mode-map (kbd "H-b") 'org-ref-bibtex-hydra/body)      
      
;;(use-package org-ref-ivy)

(define-key org-mode-map (kbd "C-c ]") 'org-ref-insert-link)


(use-package gnuplot-mode)
;; (require 'org-babel)
;; (require 'org-babel-init)
;;(require 'org-babel-gnuplot)


(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . nil)
   (C . t)
   (js . t)
   (ditaa . t)
   (ipython . t)
   (python . t)
   (gnuplot . t)
   (R . t)
   (latex . t)
   (plantuml . t)
   (shell . t)
   (jupyter . t) ) )

;; enable use of python instead of python-juptyer
(org-babel-jupyter-override-src-block "python")



;; yansippets
(use-package yasnippet
    :init
    (add-to-list 'load-path
              "~/.emacs.d/plugins/yasnippet")
;; Directory listed below first is the personal snippets directory. 
;; Early directories override later ones when there are name conflicts.
;; Snippets from all directories are pooled.
    :config
    (setq yas-snippet-dirs
          '("~/.emacs.d/snippets"                           ;; personal snippets. 
          "/Users/blaine/Dropbox/softwareDropBox/yasmate/snippets"      ;; the yasmate collection
	  "~/.emacs.d/elpa/yasnippet-snippets-20210910.1959/snippets" ;; yasnippets-snippets
            ))
    (yas-global-mode 1))


;; Enable tab triggers to work in native code language of the code block. 
(setq   org-src-tab-acts-natively t
        org-confirm-babel-evaluate nil
        org-edit-src-content-indentation 0)

;; Turn off org-mode snippets inside org-blocks
(defun my-org-mode-hook ()
  (setq-local yas-buffer-local-condition
              '(not (org-in-src-block-p t))))

;; 'my-org-mode-hook
(add-hook 'org-mode-hook `my-org-mode-hook)


;; See the scale of the preview of the LaTeX equation so you can see it.
;; Place point in equation and enter C-c C-x C-l to render.
(setq org-format-latex-options (plist-put org-format-latex-options :scale 4.0))
	
;; Open on startup
;; (find-file "~/gtd/journal/weight.org")

;; spelling
(setq ispell-program-name "/opt/local/bin/aspell")


(flycheck-define-checker proselint
  "A linter for prose."
  :command ("proselint" source-inplace)
  :error-patterns
  ((warning line-start (file-name) ":" line ":" column ": "
        (id (one-or-more (not (any " "))))
        (message) line-end))
  :modes (latex-mode text-mode markdown-mode gfm-mode))

(add-to-list 'flycheck-checkers 'proselint)


(autoload 'flycheck "flycheck" "" t)
(flycheck-define-checker textlint
  "A linter for textlint."
  :command ("npx" "textlint"
            "--config" "/Users/blaine/.emacs.d/.textlintrc"
            "--format" "unix"
            "--rule" "write-good"
            "--rule" "no-start-duplicated-conjunction"
            "--rule" "max-comma"
            "--rule" "terminology"
            "--rule" "period-in-list-item"
            "--rule" "abbr-within-parentheses"
            "--rule" "alex"
            "--rule" "common-misspellings"
            "--rule" "en-max-word-count"
            "--rule" "diacritics"
            "--rule" "stop-words"
            "--plugin"
            (eval
             (if (derived-mode-p 'tex-mode)
                 "latex"
               "@textlint/text"))
            source-inplace)
  :error-patterns
  ((warning line-start (file-name) ":" line ":" column ": "
            (message (one-or-more not-newline)
                     (zero-or-more "\n" (any " ") (one-or-more not-newline)))
            line-end))
  :modes (text-mode latex-mode org-mode markdown-mode)
  )
(add-to-list 'flycheck-checkers 'textlint)


;; org-roam
(use-package org-roam
  :ensure t
  :init
  (setq org-roam-v2-ack t)
  :custom
  (setq org-roam-directory "~/org-roam")
  (org-roam-completion-everywhere t)
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         ()
         :map org-mode-map
         ("C-M-i"    . completion-at-point))
  :config
  (org-roam-setup))

(add-to-list 'load-path "~/.emacs.d/private/org-roam-ui")
(load-library "org-roam-ui")


;; moving lines in org
(defun move-line (n)
  "Move the current line up or down by N lines."
  (interactive "p")
  (setq col (current-column))
  (beginning-of-line) (setq start (point))
  (end-of-line) (forward-char) (setq end (point))
  (let ((line-text (delete-and-extract-region start end)))
    (forward-line n)
    (insert line-text)
    ;; restore point to original column in moved line
    (forward-line -1)
    (forward-char col)))

(defun move-line-up (n)
  "Move the current line up by N lines."
  (interactive "p")
  (move-line (if (null n) -1 (- n))))

(defun move-line-down (n)
  "Move the current line down by N lines."
  (interactive "p")
  (move-line (if (null n) 1 n)))

(global-set-key (kbd "M-<up>") 'move-line-up)
(global-set-key (kbd "M-<down>") 'move-line-down)


;;  ;; word counting in subtree
;;  (defun my/count-words-in-subtree-or-region ()
;;  ;; Bind this to a key in org-mode, e.g. C-=
;;  (interactive)
;;  (call-interactively (if (region-active-p)
;;  'count-words-region
;;  'my/count-words-in-subtree)))
;;  
;;  (defun my/count-words-in-subtree ()
;;  "Count words in current node and child nodes, excluding heading text."
;;  (interactive)
;;  (org-with-wide-buffer
;;  (message "%s words in subtree"
;;  (-sum (org-map-entries
;;  (lambda ()
;;  (outline-back-to-heading)
;;  (forward-line 1)
;;  (while (or (looking-at org-keyword-time-regexp)
;;  (org-in-drawer-p))
;;  (forward-line 1))
;;  (count-words (point)
;;  (progn
;;  (outline-end-of-subtree)
;;  (point))))
;;  nil 'tree)))))


;;            ;; mode-line configuration for clojure
;;            ;; http://jr0cket.co.uk/2013/01/tweeking-emacs-modeline-for-clojure.html.html
;;            (defvar mode-line-cleaner-alist
;;              `((auto-complete-mode . " α")
;;                (yas-minor-mode . " γ")
;;                (paredit-mode . " Φ")
;;                (eldoc-mode . "")
;;                (abbrev-mode . "")
;;                (undo-tree-mode . " τ")
;;                (volatile-highlights-mode . " υ")
;;                (elisp-slime-nav-mode . " δ")
;;                (nrepl-mode . " ηζ")
;;                (nrepl-interaction-mode . " ηζ")
;;                ;; Major modes
;;                (clojure-mode . "λ")
;;                (hi-lock-mode . "")
;;                (python-mode . "Py")
;;                (emacs-lisp-mode . "EL")
;;                (markdown-mode . "md"))
;;            
;;                (defun clean-mode-line ()
;;                  (interactive)
;;                  (loop for cleaner in mode-line-cleaner-alist
;;                        do (let* ((mode (car cleaner))
;;                                 (mode-str (cdr cleaner))
;;                                 (old-mode-str (cdr (assq mode minor-mode-alist))))
;;                             (when old-mode-str
;;                                 (setcar old-mode-str mode-str))
;;                               ;; major mode
;;                             (when (eq mode major-mode)
;;                               (setq mode-name mode-str)))))
;;            
;;            (add-hook 'after-change-major-mode-hook 'clean-mode-line)
;;            
;;            
;;            
;;            ;; powerline
;;            (use-package powerline
;;                :ensure t
;;                :config
;;                (powerline-evil-vim-color-theme)
;;                (setq powerline-arrow-shape 'arrow)   ;; the default
;;                (custom-set-faces
;;                ;; custom-set-faces was added by Custom.
;;                ;; If you edit it by hand, you could mess it up, so be careful.
;;                ;; Your init file should contain only one such instance.
;;                ;; If there is more than one, they won't work right.
;;                '(mode-line ((t (:foreground "#030303" :background "#bdbdbd" :box nil))))
;;                '(mode-line-inactive ((t (:foreground "#f9f9f9" :background "#666666" :box nil)))))
;;            )
;;            
;;            
;;   
;;   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   ;; Web lookup
;;   ;; Source: \url{http://ergoemacs.org/emacs/xah-lookup.html}
;;   ;; The curlicue is the lookup word query string place-holder.
;;   
;;   (add-to-list 'load-path "~/.emacs.d/lisp/lookup-word-on-internet")
;;   (use-package 'xah-lookup)
;;   (define-key help-map (kbd "7") 'xah-lookup-web) ; C-h 7
;;   (global-set-key (kbd "<f2>") 'xah-lookup-wikipedia) ; F2
;;   
;;   
;;   
;;   (defun my-lookup-cctbx (&optional @word)
;;     "Lookup cctbx documentation of word under cursor."
;;     (interactive)
;;     (require 'xah-lookup)
;;     (xah-lookup-word-on-internet
;;      @word
;;      (get 'my-lookup-cctbx 'xah-lookup-url )
;;      (get 'my-lookup-cctbx 'xah-lookup-browser-function )))
;;   
;;   (put 'my-lookup-cctbx 'xah-lookup-url "https://cctbx.github.io/search.html?q=curlicue")
;;   (put 'my-lookup-cctbx 'xah-lookup-browser-function 'browse-url)
;;   
;;   
;;   (defun my-lookup-github (&optional @word)
;;     "Lookup github documentation of word under cursor."
;;     (interactive)
;;     (require 'xah-lookup)
;;     (xah-lookup-word-on-internet
;;      @word
;;      (get 'my-lookup-github 'xah-lookup-url )
;;      (get 'my-lookup-github 'xah-lookup-browser-function )))
;;   
;;   (put 'my-lookup-github 'xah-lookup-url "https://github.com/search?q==curlicue")
;;   (put 'my-lookup-github 'xah-lookup-browser-function 'browse-url)
;;   
;;   
;;   (defun my-lookup-jstor (&optional @word)
;;     "Lookup jstor documentation of word under cursor."
;;     (interactive)
;;     (require 'xah-lookup)
;;     (xah-lookup-word-on-internet
;;      @word
;;      (get 'my-lookup-jstor 'xah-lookup-url )
;;      (get 'my-lookup-jstor 'xah-lookup-browser-function )))
;;   
;;   (put 'my-lookup-jstor 'xah-lookup-url "https://www.jstor.org/action/doBasicSearch?Query=curlicue")
;;   (put 'my-lookup-jstor 'xah-lookup-browser-function 'browse-url)
;;   
;;   
;;   (defun my-lookup-julia (&optional @word)
;;     "Lookup cctbx documentation of word under cursor."
;;     (interactive)
;;     (require 'xah-lookup)
;;     (xah-lookup-word-on-internet
;;      @word
;;      (get 'my-lookup-julia 'xah-lookup-url )
;;      (get 'my-lookup-julia 'xah-lookup-browser-function )))
;;   
;;   (put 'my-lookup-julia 'xah-lookup-url "https://docs.julialang.org/en/v1/search/?q=curlicue")
;;   (put 'my-lookup-julia 'xah-lookup-browser-function 'browse-url)
;;   
;;   
;;   (defun my-lookup-juliaobserver (&optional @word)
;;     "Lookup cctbx documentation of word under cursor."
;;     (interactive)
;;     (require 'xah-lookup)
;;     (xah-lookup-word-on-internet
;;      @word
;;      (get 'my-lookup-juliaobserver 'xah-lookup-url )
;;      (get 'my-lookup-juliaobserver 'xah-lookup-browser-function )))
;;   
;;   (put 'my-lookup-juliaobserver 'xah-lookup-url "https://juliaobserver.com/searches?utf8=%E2%9C%93&term=curlicue")
;;   (put 'my-lookup-juliaobserver 'xah-lookup-browser-function 'browse-url)
;;   
;;   
;;   (defun my-lookup-connect (&optional @word)
;;     "lookup connected papers of word under cursor"
;;     (interactive)
;;     (require 'xah-lookup)
;;     (xah-lookup-word-on-internet
;;      @word
;;      (get 'my-lookup-connect 'xah-lookup-url )
;;      (get 'my-lookup-connect 'xah-lookup-browser-function )))
;;   
;;   (put 'my-lookup-connect 'xah-lookup-url "https://www.connectedpapers.com/search?q=curlicue")
;;   (put 'my-lookup-connect 'xah-lookup-browser-function 'browse-url)
;;   
;;   
;;   (defun my-lookup-matplotlib (&optional @word)
;;     "lookup connected papers of word under cursor"
;;     (interactive)
;;     (require 'xah-lookup)
;;     (xah-lookup-word-on-internet
;;      @word
;;      (get 'my-lookup-matplotlib 'xah-lookup-url )
;;      (get 'my-lookup-matplotlib 'xah-lookup-browser-function )))
;;   
;;   (put 'my-lookup-connect 'xah-lookup-url "https://matplotlib.org/stable/search.html?q=curlicue")
;;   (put 'my-lookup-connect 'xah-lookup-browser-function 'browse-url)
;;   
;;   
;;   
;;   (defun my-lookup-php (&optional @word)
;;     "lookup php doc of word under cursor"
;;     (interactive)
;;     (require 'xah-lookup)
;;     (xah-lookup-word-on-internet
;;      @word
;;      (get 'my-lookup-php 'xah-lookup-url )
;;      (get 'my-lookup-php 'xah-lookup-browser-function )))
;;   
;;   (put 'my-lookup-php 'xah-lookup-url "https://us.php.net/curlicue")
;;   (put 'my-lookup-php 'xah-lookup-browser-function 'browse-url)
;;   
;;   
;;   (defun my-lookup-pubmed (&optional @word)
;;     "Lookup cctbx documentation of word under cursor."
;;     (interactive)
;;     (require 'xah-lookup)
;;     (xah-lookup-word-on-internet
;;      @word
;;      (get 'my-lookup-pubmed 'xah-lookup-url )
;;      (get 'my-lookup-pubmed 'xah-lookup-browser-function )))
;;   
;;   (put 'my-lookup-pubmed 'xah-lookup-url "https://pubmed.ncbi.nlm.nih.gov/?term=curlicue")
;;   (put 'my-lookup-pubmed 'xah-lookup-browser-function 'browse-url)
;;   
;;   
;;   (defun my-lookup-pymol (&optional @word)
;;     "Lookup cctbx documentation of word under cursor."
;;     (interactive)
;;     (require 'xah-lookup)
;;     (xah-lookup-word-on-internet
;;      @word
;;      (get 'my-lookup-pymol 'xah-lookup-url )
;;      (get 'my-lookup-pymol 'xah-lookup-browser-function )))
;;   
;;   (put 'my-lookup-pymol 'xah-lookup-url "https://pymol.org/dokuwiki/doku.php?do=search&id=curlicue")
;;   (put 'my-lookup-pymol 'xah-lookup-browser-function 'browse-url)
;;   
;;   
;;   (defun my-lookup-python (&optional @word)
;;     "Lookup Python.org doc of word under cursor."
;;     (interactive)
;;     (require 'xah-lookup)
;;     (xah-lookup-word-on-internet
;;      @word
;;      (get 'my-lookup-python 'xah-lookup-url )
;;      (get 'my-lookup-python 'xah-lookup-browser-function )))
;;   
;;   (put 'my-lookup-python 'xah-lookup-url "https://www.python.org/search/?q=curlicue")
;;   (put 'my-lookup-python 'xah-lookup-browser-function 'browse-url)
;;   
;;   
;;   (defun my-lookup-r (&optional @word)
;;     "Lookup R documentation of word under cursor."
;;     (interactive)
;;     (require 'xah-lookup)
;;     (xah-lookup-word-on-internet
;;      @word
;;      (get 'my-lookup-r 'xah-lookup-url )
;;      (get 'my-lookup-r 'xah-lookup-browser-function )))
;;   
;;   (put 'my-lookup-r 'xah-lookup-url "https://www.rdocumentation.org/search?q=curlicue")
;;   (put 'my-lookup-r 'xah-lookup-browser-function 'browse-url)
;;   
;;   
;;   (defun my-lookup-scholar (&optional @word)
;;     "Lookup Goolge Scholar doc of word under cursor"
;;     (interactive)
;;     (require 'xah-lookup)
;;     (xah-lookup-word-on-internet
;;      @word
;;      (get 'my-lookup-scholar 'xah-lookup-url )
;;      (get 'my-lookup-scholar 'xah-lookup-browser-function )))
;;   
;;   (put 'my-lookup-scholar 'xah-lookup-url "https://scholar.google.com/scholar?hl=en&as_sdt=0%2C37&q=curlicue")
;;   (put 'my-lookup-scholar 'xah-lookup-browser-function 'browse-url)
;;   
;;   
;;   (defun my-lookup-wikipedia (&optional @word)
;;     "Lookup wikipedia doc of word under cursor."
;;     (interactive)
;;     (require 'xah-lookup)
;;     (xah-lookup-word-on-internet
;;      @word
;;      (get 'my-lookup-wikipedia 'xah-lookup-url )
;;      (get 'my-lookup-wikipedia 'xah-lookup-browser-function )))
;;   
;;   (put 'my-lookup-wikipedia 'xah-lookup-url "https://en.wikipedia.org/wiki/curlicue")
;;   (put 'my-lookup-wikipedia 'xah-lookup-browser-function 'browse-url)
;;   
;;   
;;   (defun my-lookup-wolframalpha (&optional @word)
;;     "Lookup wolframalpha doc of word under cursor."
;;     (interactive)
;;     (require 'xah-lookup)
;;     (xah-lookup-word-on-internet
;;      @word
;;      (get 'my-lookup-wolframalpha 'xah-lookup-url )
;;      (get 'my-lookup-wolframalpha 'xah-lookup-browser-function )))
;;   
;;   (put 'my-lookup-wolframalpha 'xah-lookup-url "https://www.wolframalpha.com/input/?i=curlicue")
;;   (put 'my-lookup-wolframalpha 'xah-lookup-browser-function 'browse-url)
;;   
;;   
;;   (defun my-lookup-pdbj (&optional @word)
;;     "Lookup wolframalpha doc of word under cursor."
;;     (interactive)
;;     (require 'xah-lookup)
;;     (xah-lookup-word-on-internet
;;      @word
;;      (get 'my-lookup-pdbj 'xah-lookup-url )
;;      (get 'my-lookup-pdbj 'xah-lookup-browser-function )))
;;   
;;   (put 'my-lookup-pdbj 'xah-lookup-url "https://pdbj.org/search/pdb?query=curlicue")
;;   (put 'my-lookup-pdbj 'xah-lookup-browser-function 'browse-url)
;;   
;;   
;;   (defun my-lookup-pdbj (&optional @word)
;;     "Lookup wolframalpha doc of word under cursor."
;;     (interactive)
;;     (require 'xah-lookup)
;;     (xah-lookup-word-on-internet
;;      @word
;;      (get 'my-lookup-tensorfolw 'xah-lookup-url )
;;      (get 'my-lookup-tensorfolw 'xah-lookup-browser-function )))
;;   
;;   (put 'my-lookup-tensorfolw 'xah-lookup-url "https://www.tensorflow.org/s/results/?q=curlicue")
;;   (put 'my-lookup-tensorfolw 'xah-lookup-browser-function 'browse-url)
;;   
;;   
;;   (define-key help-map (kbd "\C-g") 'my-lookup-github) ; C-h C-g
;;   (define-key help-map (kbd "\C-j") 'my-lookup-julia) ; C-h C-j
;;   (define-key help-map (kbd "\C-m") 'my-lookup-pymol) ; C-h C-m
;;   (define-key help-map (kbd "\C-o") 'my-lookup-juliaobserver) ; C-h C-o
;;   (define-key help-map (kbd "\C-b") 'my-lookup-pubmed) ; C-h C-b
;;   (define-key help-map (kbd "\C-t") 'my-lookup-jstor) ; C-h C-t
;;   (define-key help-map (kbd "\C-c") 'my-lookup-connect) ; C-h C-c
;;   (define-key help-map (kbd "\C-l") 'my-lookup-matplotlib) ; C-h C-l
;;   (define-key help-map (kbd "\C-p") 'my-lookup-python) ; C-h C-p
;;   (define-key help-map (kbd "\C-r") 'my-lookup-r) ; C-h C_r
;;   (define-key help-map (kbd "\C-s") 'my-lookup-scholar) ; C-h C- s
;;   (define-key help-map (kbd "\C-w") 'my-lookup-wikipedia) ; C-h C-w
;;   (define-key help-map (kbd "\C-a") 'my-lookup-wolframalpha) ; C-h C-a
;;   (define-key help-map (kbd "\C-x") 'my-lookup-cctbx) ; C-h C-x
;;   (define-key help-map (kbd "\C-f") 'my-lookup-tensorfolw) ; C-h C-f
;;   (define-key help-map (kbd "\C-d") 'my-lookup-pdbj) ; C-h C-f
;;   (put 'narrow-to-region 'disabled nil)
;;   
;;   ;;; The SBCL binary and command-line arguments 
;;   (setq inferior-lisp-program "/Users/blaine/.roswell/impls/x86-64/darwin/sbcl/2.1.9/bin/sbcl --noinform")
;;   (load (expand-file-name "~/.local/opt/quicklisp/slime-helper.el"))
;;   
;;   
;;   ;; new-dashboard
;;   ;; Function to refresh dashboard and open in current window.
;;   ;; This is useful for accessing bookmarks and recent files created in the current session
;;   ;; Source fo function: the issues section of the dashboard GitHub page.
;;   ;; Function by Jackson Benete Ferreira.
;;   ;; https://github.com/emacs-dashboard/emacs-dashboard/issues/236
;;   ;; I edited the documentation line to fix the grammar and add the final phrase.
;;   ;; Remap Open Dashboard
;;   (defun new-dashboard ()
;;     "Jump to the dashboard buffer. If it doesn't exists, create one. Refresh while at it."
;;     (interactive)
;;     (switch-to-buffer dashboard-buffer-name)
;;     (dashboard-mode)
;;     (dashboard-insert-startupify-lists)
;;     (dashboard-refresh-buffer))
;;   (global-set-key (kbd "<f1>") 'new-dashboard)
;;   
;;   
;;  ;; ------------------------------------ preview latex equations ------------------------------------ ;;
;;  ;;
;;  ;; 28.07.2017
;;  ;; Charles Wang
;;  ;;
;;  
;;;;;;; Tweaks for Org & org-latex ;;;;;;

;;    (defvar cw/org-last-fragment nil
;;      "Holds the type and position of last valid fragment we were on. Format: (FRAGMENT_TYPE FRAGMENT_POINT_BEGIN)"
;;      )
;;    
;;    (setq cw/org-valid-fragment-type
;;          '(latex-fragment
;;            latex-environment
;;            link))
;;    
;;    (defun cw/org-curr-fragment ()
;;      "Returns the type and position of the current fragment available for preview inside org-mode. Returns nil at non-displayable fragments"
;;      (let* ((fr (org-element-context))
;;             (fr-type (car fr)))
;;        (when (memq fr-type cw/org-valid-fragment-type)
;;          (list fr-type
;;                (org-element-property :begin fr))))
;;      )
;;    
;;    (defun cw/org-remove-fragment-overlay (fr)
;;      "Remove fragment overlay at fr"
;;      (let ((fr-type (nth 0 fr))
;;            (fr-begin (nth 1 fr)))
;;        (goto-char fr-begin)
;;        (cond ((or (eq 'latex-fragment fr-type)
;;                   (eq 'latex-environment fr-type))
;;               (let ((ov (loop for ov in (org--list-latex-overlays)
;;                               if
;;                               (and
;;                                (<= (overlay-start ov) (point))
;;                                (>= (overlay-end ov) (point)))
;;                               return ov)))
;;                 (when ov
;;                   (delete-overlay ov))))
;;              ((eq 'link fr-type)
;;               nil;; delete image overlay here?
;;               ))
;;        ))
;;    
;;    (defun cw/org-preview-fragment (fr)
;;      "Preview org fragment at fr"
;;      (let ((fr-type (nth 0 fr))
;;            (fr-begin (nth 1 fr)))
;;        (goto-char fr-begin)
;;        (cond ((or (eq 'latex-fragment fr-type) ;; latex stuffs
;;                   (eq 'latex-environment fr-type))
;;               (when (cw/org-curr-fragment) (org-preview-latex-fragment))) ;; only toggle preview when we're in a valid region (for inserting in the front of a fragment)
;;    
;;    
;;              ((eq 'link fr-type) ;; for images
;;               (let ((fr-end (org-element-property :end (org-element-context))))
;;                 (org-display-inline-images nil t fr-begin fr-end))))
;;        ))
;;    
;;    
;;    
;;    (defun cw/org-auto-toggle-fragment-display ()
;;      "Automatically toggle a displayable org mode fragment"
;;      (and (eq 'org-mode major-mode)
;;           (let ((curr (cw/org-curr-fragment)))
;;             (cond
;;              ;; were on a fragment and now on a new fragment
;;              ((and
;;                ;; fragment we were on
;;                cw/org-last-fragment
;;                ;; and are on a fragment now
;;                curr
;;                ;; but not on the last one this is a little tricky. as you edit the
;;                ;; fragment, it is not equal to the last one. We use the begin
;;                ;; property which is less likely to change for the comparison.
;;                (not (equal curr cw/org-last-fragment)))
;;    
;;               ;; go back to last one and put image back, provided there is still a fragment there
;;               (save-excursion
;;                 (cw/org-preview-fragment cw/org-last-fragment)
;;                 ;; now remove current image
;;                 (cw/org-remove-fragment-overlay curr)
;;                 ;; and save new fragment
;;                 )
;;               (setq cw/org-last-fragment curr))
;;    
;;              ;; were on a fragment and now are not on a fragment
;;              ((and
;;                ;; not on a fragment now
;;                (not curr)
;;                ;; but we were on one
;;                cw/org-last-fragment)
;;               ;; put image back on, provided that there is still a fragment here.
;;               (save-excursion
;;                 (cw/org-preview-fragment cw/org-last-fragment))
;;    
;;               ;; unset last fragment
;;               (setq cw/org-last-fragment nil))
;;    
;;              ;; were not on a fragment, and now are
;;              ((and
;;                ;; we were not one one
;;                (not cw/org-last-fragment)
;;                ;; but now we are
;;                curr)
;;               ;; remove image
;;               (save-excursion
;;                 (cw/org-remove-fragment-overlay curr)
;;                 )
;;               (setq cw/org-last-fragment curr))
;;    
;;              ))))
;;    
;;    ;; Suppose to negate need to toggle
;;    (add hook 'post-command-hook 'cw/org-auto-toggle-fragment-display t)
;;    

;; Cider is an interactive env for Clojure
(use-package cider
  :ensure t)

;;  ;; turn pages of clojure cookbook with M-+
;;  (defun increment-clojure-cookbook ()
;;      "When reading the Clojure cookbook, find the next section, and
;;    close the buffer. If the next section is a sub-directory or in
;;    the next chapter, open Dired so you can find it manually."
;;      (interactive)
;;      (let* ((cur (buffer-name))
;;    	 (split-cur (split-string cur "[-_]"))
;;    	 (chap (car split-cur))
;;    	 (rec (car (cdr split-cur)))
;;    	 (rec-num (string-to-number rec))
;;    	 (next-rec-num (1+ rec-num))
;;    	 (next-rec-s (number-to-string next-rec-num))
;;    	 (next-rec (if (< next-rec-num 10)
;;    		       (concat "0" next-rec-s)
;;    		     next-rec-s))
;;    	 (target (file-name-completion (concat chap "-" next-rec) "")))
;;        (progn 
;;          (if (equal target nil)
;;    	  (dired (file-name-directory (buffer-file-name)))
;;    	(find-file target))
;;          (kill-buffer cur))))
;;  
;;  (define-key adoc-mode-map (kbd "M-+") 'increment-clojure-cookbook)
;;  
;;  (add-hook 'adoc-mode-hook 'cider-mode)
;;  
;;  
;;  ;; Use the clojure-lsp
;;  (use-package lsp-mode
;;    :ensure t
;;    :hook ((clojure-mode . lsp)
;;           (clojurec-mode . lsp)
;;           (clojurescript-mode . lsp))
;;    :config
;;    ;; add paths to your local installation of project mgmt tools, like lein
;;    (setenv "PATH" (concat
;;                     "/usr/local/bin" path-separator
;;                     (getenv "PATH")))
;;    (dolist (m '(clojure-mode
;;                 clojurec-mode
;;                 clojurescript-mode
;;                 clojurex-mode))
;;       (add-to-list 'lsp-language-id-configuration `(,m . "clojure")))
;;    (setq lsp-clojure-server-command '("/usr/local/Cellar/clojure-lsp-native"))) ;; Optional: In case `clojure-lsp` is not in your $PATH
;;        
;;  