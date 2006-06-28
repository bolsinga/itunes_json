;; Turn off menu-bar
(menu-bar-mode -1)

;; Turn off backup files
(setq make-backup-files nil)

;; Always end a file with a newline
(setq require-final-newline t)

;; Tabs are always spaces
(setq-default indent-tabs-mode nil)
;; Tab key is 2 spaces
(setq-default c-basic-offset 2)

(add-to-list 'load-path (expand-file-name "~/.elisp"))
(load (expand-file-name "~/.elisp/nxml-mode-20041004/rng-auto.el"))

(setq auto-mode-alist
      (cons '("\\.\\(xml\\|xsl\\|rng\\|xhtml\\|xsd\\)\\'" . nxml-mode)
            auto-mode-alist))

;; Get perforce suport
;; (load-library "p4")
