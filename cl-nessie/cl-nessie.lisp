(ql:quickload "cffi")

(defpackage "NESSIE" (:use :cl-user :common-lisp :cffi))

(in-package "NESSIE")

(define-foreign-library lib-reader
  (t (:default "~/cl-nessie/reader")))

(use-foreign-library lib-reader)

;;(load "opcode-table.lisp");;;;will break program until finished

(defvar *file-data-array* nil)

(defcfun ("c_return_file_size_in_bytes" c-return-file-size-in-bytes) :int
  (filename :string))

(defcfun ("c_read_file_byte" c-read-file-bytes) :pointer
  (filename :string))

(defun size-of-file (filename)
  "return the number of bytes in the file"
  (with-foreign-string (file filename)
    (c-return-file-size-in-bytes file)))

(defun read-file (filename)
  "bind the file-data-array to a pointer of bytes contained in filename"
  (with-foreign-string (file filename)
    (setf *file-data-array* (c-read-file-bytes file))))

(defun write-file (op format-str operand)
  "write the disassembly to a text file"
  (with-open-file (output "disassembly.txt"
        	       :direction :output
        	       :if-exists :append
        	       :if-does-not-exist :create)
    (format output (car op) format-str operand)))

(defvar *instr-tbl* nil);;stand-in till
(defvar *format-tbl* nil);;op-code.lisp is finished

(defun disassemble-6502 (file)
  "disassemble 6502 machine code"
  (read-file file)
  (loop for i from 0 to (size-of-file file) do
        (let* ((x (mem-aref (mem-aref *file-data-array* :pointer) i))
               (op (car (gethash x *instr-tbl*)))
  	       (mode (cadr (gethash x *instr-tbl*)))
       	       (format-str (car (gethash mode *format-tbl*)))
       	       (operand nil)
       	       (operand-size (cadr (gethash op *format-tbl*))))
          (cond ((eq operand-size 2)
                   (setf operand (+  (* (mem-aref (mem-aref *file-data-array* :pointer) (+ i 1)) 256) (mem-aref (mem-aref *file-data-array* :pointer) (+ i 2))))
                   (write-file op format-str operand)
                   (setf i (+ i 2)))
                ((eq operand-size 1)
  		   (setf operand (mem-aref (mem-aref *file-data-array* :pointer) (+ i 1)))
                   (write-file op format-str operand)
                   (setf i (+ i 1))))))
  (foreign-free *file-data-array*))
                                        
              
              
              

