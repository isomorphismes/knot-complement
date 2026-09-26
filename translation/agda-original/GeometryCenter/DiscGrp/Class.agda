module GeometryCenter.DiscGrp.Class where

open import GeometryCenter.Prelude
open import GeometryCenter.Types

DiscGrpName : String
DiscGrpName = "discgrp"

-- dgclass.c installs these function pointers in GeomClass.  Function pointers
-- themselves belong to Geomview; this record preserves the exact registration
-- table without replacing it with a new object model.
record DiscGrpClassSpec : Set where
  constructor discGrpClassSpec
  field
    className : String
    nameMethod : String
    methodsMethod : String
    createMethod : String
    deleteMethod : String
    copyMethod : String
    saveMethod : String
    boundMethod : String
    pickMethod : String
    drawMethod : String
    scanMethod : String
    importMethod : String
    getMethod : String
open DiscGrpClassSpec public

DiscGrpMethods : DiscGrpClassSpec
DiscGrpMethods =
  discGrpClassSpec
    DiscGrpName
    "DiscGrpName"
    "DiscGrpMethods"
    "DiscGrpCreate"
    "DiscGrpDelete"
    "DiscGrpCopy"
    "DiscGrpFSave"
    "DiscGrpBound"
    "DiscGrpPick"
    "DiscGrpDraw"
    "DiscGrpHandleScan"
    "DiscGrpImport"
    "DiscGrpGet"
