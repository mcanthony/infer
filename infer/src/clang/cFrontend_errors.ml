(*
 * Copyright (c) 2015 - present Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 *)

(* Module for warnings detected at translation time by the frontend
 * To specify a checker define the following:
 * - condition: a boolean condition when the warning should be flagged
 * - description: a string describing the warning
 * - loc: the location where is occurs
*)

open Utils
open CFrontend_utils
open General_utils

(* === Warnings on properties === *)

let property_checkers_list = [CFrontend_checkers.checker_strong_delegate_warning]

(* Add a frontend warning with a description desc at location loc to the errlog of a proc desc *)
let log_frontend_warning pdesc warn_desc =
  let errlog = Cfg.Procdesc.get_err_log pdesc in
  let err_desc =
    Errdesc.explain_frontend_warning warn_desc.description warn_desc.suggestion
      warn_desc.loc in
  let exn = (Exceptions.Frontend_warning
               (warn_desc.name, err_desc,
                try assert false with Assert_failure x -> x)) in
  Reporting.log_error_from_errlog errlog exn

(* Call all checkers on properties of class c *)
let check_for_property_errors cfg c =
  let qual_setter setter_name =
    let cname = CContext.get_curr_class_name c in
    mk_procname_from_objc_method cname setter_name Procname.Instance_objc_method in
  let do_one_property (pname, property) =
    let (_, _, _, _, (setter_name, _), ndi) = property in
    let qual_setter = qual_setter setter_name in
    match Cfg.Procdesc.find_from_name cfg qual_setter with
    | Some pdesc_setter -> (* Property warning will be added to the proc desc of the setter *)
        Printing.log_out "Found setter for property   %s\n" pname.Clang_ast_t.ni_name;
        IList.iter (fun checker ->
            let (condition, warning_desc) = checker pname property in
            if condition then log_frontend_warning pdesc_setter warning_desc) property_checkers_list
    | None ->
        Printing.log_out "NO Setter Found for property %s\n" pname.Clang_ast_t.ni_name;
        () in
  let properties = ObjcProperty_decl.find_properties_class c in
  Printing.log_out "Retrieved all properties of the class...\n";
  IList.iter do_one_property properties
