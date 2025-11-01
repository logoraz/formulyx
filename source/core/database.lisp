;;;; Requires: cl-dbi (SQLite3 backend)
(defpackage #:frmlx/core/database
  (:use #:cl
        #:core/hlb)
  (:local-nicknames (#:dbi #:cl-dbi)
                    (#:u #:uiop))
  ;; Database management
  (:export #:*db-path*
           #:with-database
           #:initialize-database)
  (:documentation "SQLite database storing surfactants, oils, and HLB/HLD values"))
(in-package #:frmlx/core/database)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Database Configuration

(defparameter *db-path*
  (merge-pathnames "griffin/deployments.db" (u:xdg-data-home))
  "Default path for the SQLite database.")

(defparameter *db-connection* nil
  "Current database connection (dynamically bound).")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Schema Definition (TODO Update for Surfactants)

(defparameter *schema*
  '("CREATE TABLE IF NOT EXISTS deployments (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       timestamp TEXT NOT NULL DEFAULT (datetime('now')),
       hostname TEXT,
       username TEXT,
       status TEXT NOT NULL DEFAULT 'pending',
       notes TEXT
     )"
    
    "CREATE TABLE IF NOT EXISTS deployment_actions (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       deployment_id INTEGER NOT NULL,
       config_name TEXT NOT NULL,
       source_path TEXT NOT NULL,
       dest_path TEXT NOT NULL,
       spec TEXT NOT NULL,
       type TEXT NOT NULL,
       status TEXT NOT NULL DEFAULT 'pending',
       error_message TEXT,
       FOREIGN KEY (deployment_id) REFERENCES deployments(id)
     )"
    
    "CREATE TABLE IF NOT EXISTS config_snapshots (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       name TEXT NOT NULL,
       created_at TEXT NOT NULL DEFAULT (datetime('now')),
       description TEXT
     )"
    
    "CREATE TABLE IF NOT EXISTS snapshot_configs (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       snapshot_id INTEGER NOT NULL,
       config_name TEXT NOT NULL,
       source_path TEXT NOT NULL,
       dest_path TEXT NOT NULL,
       spec TEXT NOT NULL,
       type TEXT NOT NULL,
       FOREIGN KEY (snapshot_id) REFERENCES config_snapshots(id)
     )"
    
    "CREATE INDEX IF NOT EXISTS idx_deployment_timestamp 
       ON deployments(timestamp DESC)"
    
    "CREATE INDEX IF NOT EXISTS idx_actions_deployment 
       ON deployment_actions(deployment_id)")
  "SQL statements to initialize the database schema.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Database Connection Management
;;;

(defun ensure-db-directory ()
  "Ensure the database directory exists."
  (u:ensure-all-directories-exist (list *db-path*)))

(defmacro with-database ((&optional (path '*db-path*)) &body body)
  "Execute BODY with a database connection bound to *db-connection*.
Automatically handles connection opening and closing."
  `(let ((*db-path* ,path))
     (ensure-db-directory)
     ;; Using cl-dbi style - adjust if using different library
     (dbi:with-connection
         (*db-connection* :sqlite3 :database-name (u:native-namestring *db-path*))
       ,@body)))

(defun initialize-database (&optional (path *db-path*))
  "Initialize the database with the required schema."
  (with-database (path)
    (dolist (statement *schema*)
      (dbi:do-sql *db-connection* statement))
    (format t "Database initialized at: ~A~%" path)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; TODO
