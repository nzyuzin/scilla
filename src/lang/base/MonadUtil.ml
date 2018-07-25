(*
 * Copyright (c) 2018 - present Zilliqa, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 *)

open Syntax
open Core
open Result.Let_syntax

(* Monadic evaluation results *)
let fail s = Error s
let pure e = return e

(* Monadic fold-left for error *)
let rec foldM ~f ~init ls = match ls with
  | x :: ls' ->
      let%bind res = f init x in
      foldM ~f:f ~init:res ls'
  | [] -> Ok init

(* Monadic map for error *)
let rec mapM ~f ls = match ls with
  | x :: ls' ->
      (match f x, mapM ~f:f ls' with
       | Ok z, Ok zs -> Ok (z :: zs)
       | Error z as err, _ -> err
       | _, (Error _ as err) -> err)
  | [] -> Ok []



(* Try all variants in the list, pick the first successful one *)
let rec tryM ~f ls ~msg = match ls with
  | x :: ls' ->
      (match f x  with
       | Ok z -> Ok (x, z)
       | Error _ -> tryM ~f:f ls' ~msg)
  | [] -> Error msg

let liftPair2 x m = match m with
  | Ok z -> Ok (x, z)
  | Error _ as err -> err

let liftPair1 m x = match m with
  | Ok z -> Ok (z, x)
  | Error _ as err -> err
