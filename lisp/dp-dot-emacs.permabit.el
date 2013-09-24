(require 'p4)

(defconst permabit-c-style
  '((c-tab-always-indent           . t)
    (c-basic-offset                . 2)
    (c-comment-only-line-offset    . 0)
    (c-cleanup-list                . (scope-operator
				      empty-defun-braces
				      defun-close-semi
				      list-close-comma
                                      brace-else-brace
                                      brace-elseif-brace
				      knr-open-brace)) ; my own addition
    (c-offsets-alist               . ((arglist-intro     . +)
                                      ;;(defun-block-intro .
                                      ;;  c-lineup-arglist-intro-after-paren)
				      (substatement-open . 0)
				      (inline-open       . 0)
				      (cpp-macro-cont    . +)
				      (access-label      . /)
                                      ;; I see both styles and `+' is my
                                      ;; preference. And the indentation
                                      ;; Nazis haven't complained.
                                      ;;(case-label        . 0)
				      (case-label        . +)))
    (c-hanging-semi&comma-criteria dp-c-semi&comma-nada)
    (c-echo-syntactic-information-p . nil)
    (c-indent-comments-syntactically-p . t)
    (c-hanging-colons-alist         . ((member-init-intro . (before))))
    )
  "Permabit C[++] Programming Style")
(c-add-style "permabit-c-style" permabit-c-style)

(setq c-tab-always-indent t
      indent-tabs-mode nil)
(defvar dp-default-c-style-name "permabit-c-style")
(defvar dp-default-c-style permabit-c-style)

(defun dp-permabit-c-style ()
  "Set up Permabit's C style."
  (interactive)
  (c-add-style "permabit-c-style" t))

(defun dp-add-libuds ()
  (interactive)
  (setenv "LD_LIBRARY_PATH"
          (concat (getenv "libuds")
                  (getenv "LD_LIBRARY_PATH"))))

(defun dp-uds-client-setup ()
  (interactive)
  (goto-char (point-min))
  ;; eg Host:	excuses-and-accusations.permabit.com
  (when (re-search-forward "^Host:.*$" nil t)
    (dp-kill-entire-line)
    (dp-kill-entire-line))
  (when (re-search-forward "^\\s-*//spec/\\.\\.\\." nil t)
    (dp-kill-entire-line))
  ;; from   //eng/... //davep-cr/eng/...
  ;; to     //eng/albireo/... //davep-ALB-537/...
  (goto-char (point-min))
  (when (re-search-forward "//eng/\\.\\.\\." nil t)
    (replace-match "//eng/albireo/..."))
  (goto-char (point-min))
  (when (re-search-forward " //davep-\\([^/]*\\)/eng/" nil t)
    (replace-match " //davep-\\1/")))

(defvar dp-uds-index-command-regexp "/[^/]* --index.*"
  "Matches (or tries to) only index commands.
And just the command name sans path to make the command name more visible.")

(defun dp-uds-colorize-index-commands ()
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (dp-colorize-matching-lines "/[^/]* --index.*" nil nil 
                                :shrink-wrap-p t)))

(defun dp-uds-next-index-command (&optional backwards-p)
  (interactive "P")
  (if backwards-p
      (re-search-backward dp-uds-index-command-regexp nil)
    (re-search-forward dp-uds-index-command-regexp nil)))

(defun dp-uds-perl-hide-logging ()
  "Hide logging statements ($log->) for clarity.
Make language/subsystem dependent?"
  (interactive)
  (dp-colorize-matching-lines "\\$log->" :color 0 :shrink-wrap-p nil))

(defvar dpj-private-topic-re-extra
  "\\|ALB-"
  "Don't save these topics.")

(dp-add-corresponding-file-pair "uds.c" "uds-internal.h")

(add-hook 'c-mode-common-hook (lambda ()
                                (local-set-key [? ] 'dp-c*-electric-space)))

(setq dp-c*-additional-type-list
      (append
       dp-c*-additional-type-list
       '("AIPContext" "aipContext" "BlockMetadata" "blocksize_t" "buffer"
         "BufferedReader" "bufferedReader" "BufferedWriter" "bufferedWriter"
         "CachedEntry" "cachedEntry" "CFBDirectory" "CFBFat" "CFBHeader"
         "CFBValidationError" "ChapterIndexPage" "chapterIndexPage"
         "ChapterRange" "chapterRange" "ChapterWriter" "chapterWriter"
         "ChunkMetadata" "Configuration" "configuration"
         "ContextStatsMessageData" "contextStatsMessageData" "ContextType"
         "controlOpData" "DeltaIndex" "deltaIndex" "DeltaIndexEntry"
         "deltaIndexEntry" "DeltaIndexStats" "deltaIndexStats" "DeltaList"
         "deltaList" "DeltaListSaveInfo" "deltaListSaveInfo" "DeltaMemory"
         "deltaMemory" "DeltaPageHeader" "DirectoryEntryProcessor"
         "dm1_header" "EntryCache" "entryCache" "eventCount" "FileAccess"
         "FileSyncer" "fileSyncer" "filetime_t" "Geometry" "geometry" "Grid"
         "grid" "GridType" "HashInfo" "hashInfo" "Histogram" "histogram"
         "IncrementalWriterCommand" "incrementalWriterCommand" "Index"
         "index" "IndexCheckpointTriggerValue" "indexCheckpointTriggerValue"
         "IndexComponent" "indexComponent" "IndexComponentFile"
         "IndexIterator" "indexIterator" "IndexLocation" "indexLocation"
         "IndexLookupMode" "indexLookupMode" "IndexPageBounds" "IndexPageMap"
         "IndexPageMapEntry" "IndexReader" "indexReader" "IndexReaderState"
         "IndexRegion" "IndexRouter" "indexRouter" "IndexRouterMethods"
         "indexRouterMethods" "IndexRouterStatCounters"
         "indexRouterStatCounters" "IndexSession" "indexSession"
         "IndexSessionState" "indexSessionState" "IndexStatCounters"
         "indexStatCounters" "IndexState" "indexState" "IndexStateData300"
         "IndexStateData301" "IndexStateFile" "IndexStateVersion"
         "IndexStatsMessageData" "indexStatsMessageData"
         "indexStatsMessageData " "LoaderContext" "LoadType"
         "LocalIndexRouterPrivate" "localIndexRouterPrivate" "MasterIndex"
         "masterIndex" "MasterIndexOps" "masterIndexOps" "MasterIndexRecord"
         "masterIndexRecord" "mi005_data" "mi006_data" "MigrationHeader"
         "migrationHeader" "MigrationReadyMsg" "migrationReadyMsg" "Module"
         "module" "NamespaceHash" "namespaceHash" "OldSlot" "OpenChapter"
         "openChapter" "OpenChapterIndex" "openChapterIndex" "OptionSet"
         "optionSet" "OptionSetId" "PathBuffer" "pathBuffer" "PrintMode"
         "PRIORITY_NAMES" "ProgramArgs" "QueuedRead" "queuedRead"
         "readerConnection" "ReaderState" "RemoteIndexRouterPrivate"
         "remoteIndexRouterPrivate" "RequestAction" "RequestQueueWork"
         "scanContext" "scanIndex" "Scanner" "scanner" "ScannerAction"
         "scannerAction" "ScannerContext" "scannerContext" "ScannerFTable"
         "scannerFTable" "ScannerType" "ScanningMode" "secloc_error_t"
         "sector_loc_t" "ServerConnection" "serverConnection"
         "ServerConnectionHead" "serverConnectionHead" "ServerReplyHead"
         "serverReplyHead" "Session" "session" "SessionGroup" "sessionGroup"
         "SessionListHead" "sessionListHead" "SocketType" "SparseFillPhase"
         "StatCounters" "statCounters" "stats" "streamid_t" "StringDisplay"
         "stringDisplay" "syncEntry" "Task" "TraceMetadata" "UdsBlockContext"
         "udsBlockContext" "UdsBuffer" "UdsCallbackType" "UdsChunkData"
         "udsChunkData" "UdsChunkName" "udsChunkName" "UdsChunkRecord"
         "udsConfiguration" "udsConfiguration3_0" "UdsContext" "udsContext"
         "UdsContextState" "udsContextState" "UdsContextStats"
         "udsContextStats" "UdsFileContext" "udsFileContext" "UdsGlobalState"
         "udsGlobalState" "udsGridConfig" "UdsGState"
         "UdsIndexRouterQueueHead" "udsIndexRouterQueueHead"
         "UdsIndexSession" "udsIndexSession" "UdsIndexStats" "udsIndexStats"
         "UdsNamespace" "udsNamespace" "UdsPartialSegment"
         "udsPartialSegment" "UdsQueueHead" "udsQueueHead" "UdsRequest"
         "udsRequest" "UdsRequestQueue" "udsRequestQueue"
         "UdsRequestQueueFilter" "UdsRequestQueueHead" "udsRequestQueueHead"
         "UdsRequestQueueProcessor" "udsStream" "UdsStreamContext"
         "udsStreamContext" "uint8_t" "utf16_t" "Volume" "volume"
         "VolumeCache" "volumeCache" "BandedStreamDef" "bandedStreamDef"
         "AnyStreamDef" "anyStreamDef" "SimpleStreamDef" "simpleStreamDef"
         "AliasStreamDef" "aliasStreamDef" 
         "ShuffledStreamDef" "shuffledStreamDef"
         "MixedStreamDef" "mixedStreamDef" "AnyStreamDef" "anyStreamDef"
         "BandedStream" "bandedStream"
         "AnyStream" "anyStream" "SimpleStream" "simpleStream"
         "AliasStream" "aliasStream" 
         "ShuffledStream" "shuffledStream"
         "MixedStream" "mixedStream" "AnyStream" "anyStream"
         )
       ))
(getenv "LD_LIBRARY_PATH")
(setq cscope-program "dp-cscope")

(setq dp-c-format-func-decl-align-p-default t)

(defun dp-mark-all-of-xxx (regexp stay-put-p)
  "Mark 'dedupe percentage' lines (quotes are not in the regexp).
The ultimate in laziness?"
  (interactive "sRegexp: \nP")
  (unless stay-put-p
    (dp-push-go-back "markddp")
    (goto-char (point-min)))
  (dp-colorize-matching-lines regexp))

(defun dp-mark-dedupe-percentages (stay-put-p)
  (interactive "P")
  (dp-mark-all-of-xxx "^.*dedupe percentage.*$" stay-put-p))
(dp-defaliases 'mddp 'cddp 'dp-mark-dedupe-percentages)

(defun dp-mark-albGenTests (stay-put-p)
  (interactive "P")
  (dp-mark-all-of-xxx "^.*/albGenTest --index.*$" stay-put-p))
(dp-defaliases 'magt 'cagt 'dp-mark-albGenTests)

(defun dp-mark-scan-rates (stay-put-p)
  (interactive "P")
  (dp-mark-all-of-xxx "^.*scan rate.*$" stay-put-p))
(dp-defaliases 'msr 'csr 'dp-mark-scan-rates)

;; Some icky Perl junk... until no longer needed.
;; convert a my $var = <junk> to
;; $log->debug("var>$var<");
;; for debugging
(defalias 'dp-perl-my-var-to-log-debug 
  (read-kbd-macro
   (concat 
    "C-a <C-right> <right> "
    "2*<C-backspace> $log- > "
    "debug( <right> M-a C-s = "
    "2*<left> M-o <C-left> <backspace> "
    "\" <C-right> > $ M-y < M-k ); "
    "2*<backspace> \"); <right>")))

(dp-add-list-to-list 'dp-force-read-only-regexps
                     '("/work/z2/"
                       "/work/z1/"))
