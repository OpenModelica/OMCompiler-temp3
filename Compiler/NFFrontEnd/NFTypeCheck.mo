/*
 * This file is part of OpenModelica.
 *
 * Copyright (c) 1998-2014, Open Source Modelica Consortium (OSMC),
 * c/o Linköpings universitet, Department of Computer and Information Science,
 * SE-58183 Linköping, Sweden.
 *
 * All rights reserved.
 *
 * THIS PROGRAM IS PROVIDED UNDER THE TERMS OF GPL VERSION 3 LICENSE OR
 * THIS OSMC PUBLIC LICENSE (OSMC-PL) VERSION 1.2.
 * ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS PROGRAM CONSTITUTES
 * RECIPIENT'S ACCEPTANCE OF THE OSMC PUBLIC LICENSE OR THE GPL VERSION 3,
 * ACCORDING TO RECIPIENTS CHOICE.
 *
 * The OpenModelica software and the Open Source Modelica
 * Consortium (OSMC) Public License (OSMC-PL) are obtained
 * from OSMC, either from the above address,
 * from the URLs: http://www.ida.liu.se/projects/OpenModelica or
 * http://www.openmodelica.org, and in the OpenModelica distribution.
 * GNU version 3 is obtained from: http://www.gnu.org/copyleft/gpl.html.
 *
 * This program is distributed WITHOUT ANY WARRANTY; without
 * even the implied warranty of  MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE, EXCEPT AS EXPRESSLY SET FORTH
 * IN THE BY RECIPIENT SELECTED SUBSIDIARY LICENSE CONDITIONS OF OSMC-PL.
 *
 * See the full OSMC Public License conditions for more details.
 *
 */

encapsulated package NFTypeCheck
" file:        NFTypeCheck.mo
  package:     NFTypeCheck
  description: SCodeInst type checking.


  Functions used by SCodeInst for type checking and type conversion where needed.
"

//public import Absyn;
//public import NFConnect2;
public import DAE;
//public import HashTablePathToFunction;
//public import NFInstSymbolTable;
//public import NFInstTypes;
//public import NFTyping;
//public import DAEDump;
//public import Util;
//
//public type Binding = NFInstTypes.Binding;
//public type Class = NFInstTypes.Class;
//public type Component = NFInstTypes.Component;
//public type Connections = NFConnect2.Connections;
//public type Connector = NFConnect2.Connector;
//public type ConnectorType = NFConnect2.ConnectorType;
//public type DaePrefixes = NFInstTypes.DaePrefixes;
//public type Dimension = NFInstTypes.Dimension;
//public type Element = NFInstTypes.Element;
//public type Equation = NFInstTypes.Equation;
//public type Face = NFConnect2.Face;
//public type Function = NFInstTypes.Function;
//public type FunctionTable = HashTablePathToFunction.HashTable;
//public type Modifier = NFInstTypes.Modifier;
//public type ParamType = NFInstTypes.ParamType;
//public type Prefixes = NFInstTypes.Prefixes;
//public type Statement = NFInstTypes.Statement;
//public type SymbolTable = NFInstSymbolTable.SymbolTable;
//public type Context = NFTyping.Context;
//public type EvalPolicy = NFTyping.EvalPolicy;
//
protected import Debug;
protected import DAEDump;
protected import Error;
protected import Expression;
protected import ExpressionDump;
//protected import Flags;
//protected import NFInstUtil;
//protected import List;
protected import Types;
//
//
//public function checkClassComponents
//  input Class inClass;
//  input Context inContext;
//  input SymbolTable inSymbolTable;
//  output Class outClass;
//  output SymbolTable outSymbolTable;
//algorithm
//  (outClass, outSymbolTable) :=
//    checkClass(inClass, NONE(), inContext, inSymbolTable);
//end checkClassComponents;
//
//public function checkClass
//  input Class inClass;
//  input Option<Component> inParent;
//  input Context inContext;
//  input SymbolTable inSymbolTable;
//  output Class outClass;
//  output SymbolTable outSymbolTable;
//algorithm
//  (outClass, outSymbolTable) := match(inClass, inParent, inContext, inSymbolTable)
//    local
//      list<Element> comps;
//      list<Equation> eq, ieq;
//      list<list<Statement>> al, ial;
//      SymbolTable st;
//      Absyn.Path name;
//
//    case (NFInstTypes.BASIC_TYPE(_), _, _, st) then (inClass, st);
//
//    case (NFInstTypes.COMPLEX_CLASS(name, comps, eq, ieq, al, ial), _, _, st)
//      equation
//        (comps, st) = List.map2Fold(comps, checkElement, inParent, inContext, st);
//      then
//        (NFInstTypes.COMPLEX_CLASS(name, comps, eq, ieq, al, ial), st);
//
//  end match;
//end checkClass;
//
//protected function checkElement
//  input Element inElement;
//  input Option<Component> inParent;
//  input Context inContext;
//  input SymbolTable inSymbolTable;
//  output Element outElement;
//  output SymbolTable outSymbolTable;
//algorithm
//  (outElement, outSymbolTable) :=
//  match(inElement, inParent, inContext, inSymbolTable)
//    local
//      Component comp;
//      Class cls;
//      Absyn.Path name;
//      SymbolTable st;
//      SourceInfo info;
//      String str;
//
//    case (NFInstTypes.ELEMENT(NFInstTypes.UNTYPED_COMPONENT(name = name, info = info), _),
//        _, _, _)
//      equation
//        str = "Found untyped component: " + Absyn.pathString(name);
//        Error.addSourceMessage(Error.INTERNAL_ERROR, {str}, info);
//      then
//        fail();
//
//    case (NFInstTypes.ELEMENT(comp, cls), _, _, st)
//      equation
//        (comp, st)= checkComponent(comp, inParent, inContext, st);
//        (cls, st) = checkClass(cls, SOME(comp), inContext, st);
//      then
//        (NFInstTypes.ELEMENT(comp, cls), st);
//
//    case (NFInstTypes.CONDITIONAL_ELEMENT(_), _, _, _)
//      then (inElement, inSymbolTable);
//
//  end match;
//end checkElement;
//
//protected function checkComponent
//  input Component inComponent;
//  input Option<Component> inParent;
//  input Context inContext;
//  input SymbolTable inSymbolTable;
//  output Component outComponent;
//  output SymbolTable outSymbolTable;
//algorithm
//  (outComponent, outSymbolTable) :=
//  match(inComponent, inParent, inContext, inSymbolTable)
//    local
//      Absyn.Path name;
//      DAE.Type ty;
//      Binding binding;
//      SymbolTable st;
//      Component comp, inner_comp;
//      Context c;
//      String str;
//      SourceInfo info;
//
//    case (NFInstTypes.UNTYPED_COMPONENT(name = name,  info = info),
//        _, _, _)
//      equation
//        str = "Found untyped component: " + Absyn.pathString(name);
//        Error.addSourceMessage(Error.INTERNAL_ERROR, {str}, info);
//      then
//        fail();
//
//    // check and convert if needed the type of
//    // the binding vs the type of the component
//    case (NFInstTypes.TYPED_COMPONENT(), _, _, st)
//      equation
//        comp = NFInstUtil.setComponentParent(inComponent, inParent);
//        comp = checkComponentBindingType(comp);
//      then
//        (comp, st);
//
//    case (NFInstTypes.OUTER_COMPONENT(innerName = SOME(name)), _, _, st)
//      equation
//        comp = NFInstSymbolTable.lookupName(name, st);
//        (comp, st) = checkComponent(comp, inParent, inContext, st);
//      then
//        (comp, st);
//
//    case (NFInstTypes.OUTER_COMPONENT( innerName = NONE()), _, _, st)
//      equation
//        (_, SOME(inner_comp), st) = NFInstSymbolTable.updateInnerReference(inComponent, st);
//        (inner_comp, st) = checkComponent(inner_comp, inParent, inContext, st);
//      then
//        (inner_comp, st);
//
//    case (NFInstTypes.CONDITIONAL_COMPONENT(name = name), _, _, _)
//      equation
//        print("Trying to type conditional component " + Absyn.pathString(name) + "\n");
//      then
//        fail();
//
//    case (NFInstTypes.DELETED_COMPONENT(), _, _, st)
//      then (inComponent, st);
//
//  end match;
//end checkComponent;
//
//protected function checkComponentBindingType
//  input Component inC;
//  output Component outC;
//algorithm
//  outC := matchcontinue (inC)
//    local
//      DAE.Type ty, propagatedTy, convertedTy;
//      Absyn.Path name, eName;
//      Option<Component> parent;
//      DaePrefixes prefixes;
//      Binding binding;
//      SourceInfo info;
//      DAE.Exp bindingExp;
//      DAE.Type bindingType;
//      Integer propagatedDims "See NFSCodeMod.propagateMod.";
//      SourceInfo binfo;
//      String nStr, eStr, etStr, btStr;
//      DAE.Dimensions parentDimensions;
//
//    // nothing to check
//    case (NFInstTypes.TYPED_COMPONENT(binding = NFInstTypes.UNBOUND()))
//      then
//        inC;
//
//    // when the component name is equal to the component type we have a constant enumeration!
//    // StateSelect = {StateSelect.always, StateSelect.prefer, StateSelect.default, StateSelect.avoid, StateSelect.never}
//    case (NFInstTypes.TYPED_COMPONENT(name = name, ty = DAE.T_ENUMERATION(path = eName)))
//      equation
//        true = Absyn.pathEqual(name, eName);
//      then
//        inC;
//
//    case (NFInstTypes.TYPED_COMPONENT(name, ty, parent, prefixes, binding, info))
//      equation
//        NFInstTypes.TYPED_BINDING(bindingExp, bindingType, propagatedDims, binfo) = binding;
//        parentDimensions = getParentDimensions(parent, {});
//        propagatedTy = liftArray(ty, parentDimensions, propagatedDims);
//        (bindingExp, convertedTy) = Types.matchType(bindingExp, bindingType, propagatedTy, true);
//        binding = NFInstTypes.TYPED_BINDING(bindingExp, convertedTy, propagatedDims, binfo);
//      then
//        NFInstTypes.TYPED_COMPONENT(name, ty, parent, prefixes, binding, info);
//
//    case (NFInstTypes.TYPED_COMPONENT(name, ty, parent, _, binding, info))
//      equation
//        NFInstTypes.TYPED_BINDING(bindingExp, bindingType, propagatedDims, _) = binding;
//        parentDimensions = getParentDimensions(parent, {});
//        propagatedTy = liftArray(ty, parentDimensions, propagatedDims);
//        failure((_, _) = Types.matchType(bindingExp, bindingType, propagatedTy, true));
//        nStr = Absyn.pathString(name);
//        eStr = ExpressionDump.printExpStr(bindingExp);
//        etStr = Types.unparseTypeNoAttr(propagatedTy);
//        etStr = etStr + " propDim: " + intString(propagatedDims);
//        btStr = Types.unparseTypeNoAttr(bindingType);
//        Error.addSourceMessage(Error.VARIABLE_BINDING_TYPE_MISMATCH,
//        {nStr, eStr, etStr, btStr}, info);
//      then
//        fail();
//
//    else
//      equation
//        //name = NFInstUtil.getComponentName(inC);
//        //nStr = "Found untyped component: " + Absyn.pathString(name);
//        //Error.addMessage(Error.INTERNAL_ERROR, {nStr});
//      then
//        fail();
//
//  end matchcontinue;
//end checkComponentBindingType;
//
//protected function getParentDimensions
//"get the dimensions from the parents of the component up to the root"
//  input Option<Component> inParentOpt;
//  input DAE.Dimensions inDimensionsAcc;
//  output DAE.Dimensions outDimensions;
//algorithm
//  outDimensions := matchcontinue(inParentOpt, inDimensionsAcc)
//    local
//      Component c;
//      DAE.Dimensions dims;
//
//    case (NONE(), _) then inDimensionsAcc;
//
//    case (SOME(c), _)
//      equation
//        dims = NFInstUtil.getComponentTypeDimensions(c);
//        dims = listAppend(dims, inDimensionsAcc);
//        dims = getParentDimensions(NFInstUtil.getComponentParent(c), dims);
//      then
//        dims;
//    // for other...
//    case (SOME(_), _) then inDimensionsAcc;
//  end matchcontinue;
//end getParentDimensions;
//
//protected function liftArray
// input DAE.Type inTy;
// input DAE.Dimensions inParentDimensions;
// input Integer inPropagatedDims;
// output DAE.Type outTy;
//algorithm
// outTy := matchcontinue(inTy, inParentDimensions, inPropagatedDims)
//   local
//     Integer pdims;
//     DAE.Type ty;
//     DAE.Dimensions dims;
//     DAE.TypeSource ts;
//
//   case (_, _, -1) then inTy;
//   // TODO! FIXME! check if we can actually have propagated dims of 0
//   case (_, {}, 0) then inTy;
//   // we have some parent dims
//   case (_, _::_, 0)
//     equation
//       ts = Types.getTypeSource(inTy);
//       ty = DAE.T_ARRAY(inTy, inParentDimensions, ts);
//     then ty;
//   // we can take the lastN from the propagated dims!
//   case (_, _, pdims)
//     equation
//       false = Types.isArray(inTy);
//       ts = Types.getTypeSource(inTy);
//       dims = List.lastN(inParentDimensions, pdims);
//       ty = DAE.T_ARRAY(inTy, dims, ts);
//     then
//       ty;
//   // we can take the lastN from the propagated dims!
//   case (_, _, pdims)
//     equation
//       true = Types.isArray(inTy);
//       ty = Types.unliftArray(inTy);
//       ts = Types.getTypeSource(inTy);
//       dims = listAppend(inParentDimensions, Types.getDimensions(inTy));
//       dims = List.lastN(dims, pdims);
//       ty = DAE.T_ARRAY(ty, dims, ts);
//     then
//       ty;
//    case (_, {}, _) then inTy;
//    else DAE.T_ARRAY(inTy, inParentDimensions, DAE.emptyTypeSource);
//  end matchcontinue;
//end liftArray;
//
//public function checkExpEquality
//  input DAE.Exp inExp1;
//  input DAE.Type inTy1;
//  input DAE.Exp inExp2;
//  input DAE.Type inTy2;
//  input String inMessage;
//  input SourceInfo inInfo;
//  output DAE.Exp outExp1;
//  output DAE.Type outTy1;
//  output DAE.Exp outExp2;
//  output DAE.Type outTy2;
//algorithm
//  (outExp1, outTy1, outExp2, outTy2) := matchcontinue(inExp1, inTy1, inExp2, inTy2, inMessage, inInfo)
//    local
//      DAE.Exp e;
//      DAE.Type t;
//      String e1Str, t1Str, e2Str, t2Str, s1, s2;
//
//    // Check if the Rhs matchs/can be converted to match the Lhs
//    case (_, _, _, _, _, _)
//      equation
//        (e, t) = Types.matchType(inExp2, inTy2, inTy1, true);
//      then
//        (inExp1, inTy1, e, t);
//
//    // the other way arround just for equations!
//    case (_, _, _, _, "equ", _)
//      equation
//        (e, t) = Types.matchType(inExp1, inTy1, inTy2, true);
//      then
//        (e, t, inExp2, inTy2);
//
//    // not really fine!
//    case (_, _, _, _, "equ", _)
//      equation
//        e1Str = ExpressionDump.printExpStr(inExp1);
//        t1Str = Types.unparseTypeNoAttr(inTy1);
//        e2Str = ExpressionDump.printExpStr(inExp2);
//        t2Str = Types.unparseTypeNoAttr(inTy2);
//        s1 = stringAppendList({e1Str,"=",e2Str});
//        s2 = stringAppendList({t1Str,"=",t2Str});
//        Error.addSourceMessage(Error.EQUATION_TYPE_MISMATCH_ERROR, {s1,s2}, inInfo);
//        true = Flags.isSet(Flags.FAILTRACE);
//        Debug.traceln("- NFTypeCheck.checkExpEquality failed with type mismatch: " + s1 + " tys: " + s2);
//      then
//        fail();
//
//    case (_, _, _, _, "alg", _)
//      equation
//        e1Str = ExpressionDump.printExpStr(inExp1);
//        t1Str = Types.unparseTypeNoAttr(inTy1);
//        e2Str = ExpressionDump.printExpStr(inExp2);
//        t2Str = Types.unparseTypeNoAttr(inTy2);
//        s1 = stringAppendList({e1Str,":=",e2Str});
//        s2 = stringAppendList({t1Str,":=",t2Str});
//        Error.addSourceMessage(Error.ASSIGN_TYPE_MISMATCH_ERROR, {e1Str,e2Str,t1Str,t2Str}, inInfo);
//        true = Flags.isSet(Flags.FAILTRACE);
//        Debug.traceln("- NFTypeCheck.checkExpEquality failed with type mismatch: " + s1 + " tys: " + s2);
//      then
//        fail();
//  end matchcontinue;
//end checkExpEquality;
//
//
//
//
// ************************************************************** //
//   BEGIN: Operator typing helper functions
// ************************************************************** //


public function checkLogicalBinaryOperation
  "mahge:
  Type checks logical binary operations. operations on scalars are handled
  simply by using Types.matchType().
  Operations involving Complex types are handled differently."
  input DAE.Exp exp1;
  input DAE.Type type1;
  input DAE.Operator operator;
  input DAE.Exp exp2;
  input DAE.Type type2;
  output DAE.Exp exp;
  output DAE.Type ty;
protected
  DAE.Exp e1, e2;
  DAE.Operator op;
  DAE.TypeSource ty_src;
  String e1_str, e2_str, ty1_str, ty2_str, msg_str, op_str, s1, s2;
algorithm
  try
    true := Types.isBoolean(type1) and Types.isBoolean(type2);

    // Logical binary operations here are allowed only on Booleans.
    // The Modelica Specification 3.2 doesn't say anything if they should be
    // allowed or not on scalars of type Integers/Reals.
    // It says no for arrays of Integer/Real type.
    (e1, e2, ty) := matchTypeBothWays(exp1, type1, exp2, type2);
    op := Expression.setOpType(operator, ty);

    exp := DAE.LBINARY(e1, op, e2);
  else
    e1_str := ExpressionDump.printExpStr(exp1);
    e2_str := ExpressionDump.printExpStr(exp2);
    ty1_str := Types.unparseTypeNoAttr(type1);
    ty2_str := Types.unparseTypeNoAttr(type2);
    op_str := DAEDump.dumpOperatorString(operator);

    // Check if we have relational operations involving array types.
    // Just for proper error messages.
    msg_str := if not (Types.isBoolean(type1) or Types.isBoolean(type2)) then
      "\n: Logical operations involving non-Boolean types are not valid in Modelica." else ty1_str;

    s1 := "' " + e1_str + op_str + e2_str + " '";
    s2 := "' " + ty1_str + op_str + ty2_str + " '";

    Error.addSourceMessage(Error.UNRESOLVABLE_TYPE, {s1, s2, msg_str}, Absyn.dummyInfo);
  end try;
end checkLogicalBinaryOperation;

public function checkLogicalUnaryOperation
  "petfr:
  Typechecks logical unary operations, i.e. the not operator"
  input DAE.Exp exp1;
  input DAE.Type type1;
  input DAE.Operator operator;
  output DAE.Exp exp;
  output DAE.Type ty;
protected
  DAE.Exp e1;
  DAE.Operator op;
  DAE.TypeSource ty_src;
  String e1_str, ty1_str, msg_str, op_str, s1;
algorithm
  try
    true := Types.isBoolean(type1);
    // Logical unary operations here are allowed only on Booleans.
    ty := type1;
    op := Expression.setOpType(operator, ty);
    exp := DAE.LUNARY(op, exp1);

  else
    e1_str := ExpressionDump.printExpStr(exp1);
    ty1_str := Types.unparseTypeNoAttr(type1);
    op_str := DAEDump.dumpOperatorString(operator);

    // Just for proper error messages.
    msg_str := if not (Types.isBoolean(type1)) then
      "\n: Logical operations involving non-Boolean types are not valid in Modelica." else ty1_str;

    s1 := "' " + e1_str + op_str  + " '";

    Error.addSourceMessage(Error.UNRESOLVABLE_TYPE, {s1, msg_str}, Absyn.dummyInfo);
  end try;
end checkLogicalUnaryOperation;

public function checkRelationOperation
  "mahge:
  Type checks relational operations. Relations on scalars are handled
  simply by using Types.matchType(). This way conversions from Integer to real
  are handled internaly."
  input DAE.Exp exp1;
  input DAE.Type type1;
  input DAE.Operator operator;
  input DAE.Exp exp2;
  input DAE.Type type2;
  output DAE.Exp exp;
  output DAE.Type ty;
protected
  DAE.Exp e1, e2;
  DAE.Operator op;
  DAE.TypeSource ty_src;
  String e1_str, e2_str, ty1_str, ty2_str, msg_str, op_str, s1, s2;
algorithm
  try
    true := Types.isSimpleType(type1) and Types.isSimpleType(type2);

    // Check types match/can be converted to match.
    (e1, e2, ty) := matchTypeBothWays(exp1, type1, exp2, type2);
    ty_src := Types.getTypeSource(ty);
    ty := DAE.T_BOOL({}, ty_src);
    op := Expression.setOpType(operator, ty);

    exp := DAE.RELATION(e1, op, e2, -1, NONE());
  else
    e1_str := ExpressionDump.printExpStr(exp1);
    e2_str := ExpressionDump.printExpStr(exp2);
    ty1_str := Types.unparseTypeNoAttr(type1);
    ty2_str := Types.unparseTypeNoAttr(type2);
    op_str := DAEDump.dumpOperatorString(operator);

    // Check if we have relational operations involving array types.
    // Just for proper error messages.
    msg_str := if Types.arrayType(type1) or Types.arrayType(type2) then
      "\n: Relational operations involving array types are not valid in Modelica." else ty1_str;

    s1 := "' " + e1_str + op_str + e2_str + " '";
    s2 := "' " + ty1_str + op_str + ty2_str + " '";

    Error.addSourceMessage(Error.UNRESOLVABLE_TYPE, {s1, s2, msg_str}, Absyn.dummyInfo);
  end try;
end checkRelationOperation;

public function checkBinaryOperation
  "mahge:
  Type checks binary operations. operations on scalars are handled
  simply by using Types.matchType(). This way conversions from Integer to Real
  are handled internally.
  Operations involving arrays and Complex types are handled differently."
  input DAE.Exp exp1;
  input DAE.Type type1;
  input DAE.Operator operator;
  input DAE.Exp exp2;
  input DAE.Type type2;
  output DAE.Exp binaryExp;
  output DAE.Type binaryType;
protected
  DAE.Exp e1, e2;
  DAE.Operator op;
  DAE.TypeSource ty_src;
  String e1_str, e2_str, ty1_str, ty2_str, s1, s2;
algorithm
  // All operators expect Numeric types except Addition.
  true := checkValidNumericTypesForOp(type1, type2, operator, true);

  try
    if Types.isSimpleType(type1) and Types.isSimpleType(type2) then
      // Binary expression with expression of simple type.

      (e1, e2, binaryType) := match operator
        // Addition operations on Scalars.
        // Check if the operands (match/can be converted to match) the other.
        case DAE.ADD()
          then matchTypeBothWays(exp1, type1, exp2, type2);

        case DAE.SUB()
          then matchTypeBothWays(exp1, type1, exp2, type2);

        case DAE.MUL()
          then matchTypeBothWays(exp1, type1, exp2, type2);

        // Check division operations.
        // They result in T_REAL regardless of the operand types.
        case DAE.DIV()
          algorithm
            (e1, e2, binaryType) := matchTypeBothWays(exp1, type1, exp2, type2);

            ty_src := Types.getTypeSource(type1);
          then
            (e1, e2, DAE.T_REAL({}, ty_src));

        // Check exponentiations.
        // They result in T_REAL regardless of the operand types.
        // According to spec operands should be promoted to real before expon.
        // to fit with ANSI C ???.
        case DAE.POW()
          algorithm
            // Try converting both to Real type.
            (e1, binaryType) := Types.matchType(exp1, type1, DAE.T_REAL_DEFAULT, true);
            (e2, _) := Types.matchType(exp2, type2, DAE.T_REAL_DEFAULT, true);

            ty_src := Types.getTypeSource(type1);
          then
            (e1, e2, DAE.T_REAL({}, ty_src));

      end match;

      op := Expression.setOpType(operator, binaryType);
      binaryExp := DAE.BINARY(e1, op, e2);
    else
      // Binary expression with expressions of array type.
      (binaryExp, binaryType) := checkBinaryOperationArrays(exp1, type1, operator, exp2, type2);
    end if;
  else
    e1_str := ExpressionDump.printExpStr(exp1);
    e2_str := ExpressionDump.printExpStr(exp2);
    ty1_str := Types.unparseTypeNoAttr(type1);
    ty2_str := Types.unparseTypeNoAttr(type2);
    s1 := "' " + e1_str + DAEDump.dumpOperatorSymbol(operator) + e2_str + " '";
    s2 := "' " + ty1_str + DAEDump.dumpOperatorSymbol(operator) + ty2_str + " '";
    Error.addSourceMessage(Error.UNRESOLVABLE_TYPE, {s1, s2, ty1_str}, Absyn.dummyInfo);
    fail();
  end try;
end checkBinaryOperation;

public function checkUnaryOperation
  "petfr:
  Type checks arithmetic unary operations. Both for simple scalar types and
  operations involving array types. Builds DAE unary node."
  input DAE.Exp exp1;
  input DAE.Type type1;
  input DAE.Operator operator;
  output DAE.Exp unaryExp;
  output DAE.Type unaryType;
protected
  DAE.Operator op;
  DAE.TypeSource ty_src;
  String e1_str, ty1_str, s1;
algorithm
  try
    // Arithmetic type expected for Unary operators, i.e., UMINUS, UMINUS_ARR;  UPLUS removed
    true := Types.isNumericType(type1);

    unaryType := type1;
    op := Expression.setOpType(operator, unaryType);
    unaryExp := match op
              case DAE.ADD() then exp1; // If UNARY +, +exp1, remove it since no unary DAE.ADD
              else DAE.UNARY(op, exp1);
            end match;
  else
    e1_str := ExpressionDump.printExpStr(exp1);
    ty1_str := Types.unparseTypeNoAttr(type1);
    s1 := "' " + e1_str + DAEDump.dumpOperatorSymbol(operator) + " '" +
       " Arithmetic type expected for this unary operator ";
    Error.addSourceMessage(Error.UNRESOLVABLE_TYPE, {s1, ty1_str}, Absyn.dummyInfo);
    fail();
  end try;
end checkUnaryOperation;

public function checkBinaryOperationArrays
  "mahge:
  Type checks binary operations involving arrays. This involves more checks than
  scalar types. All normal operations as well as element wise operations involving
  arrays are handled here."
  input DAE.Exp inExp1;
  input DAE.Type inType1;
  input DAE.Operator inOp;
  input DAE.Exp inExp2;
  input DAE.Type inType2;
  output DAE.Exp outExp;
  output DAE.Type outType;
protected
  Boolean isArray1,isArray2, bothArrays;
  Integer nrDims1, nrDims2;
algorithm

  nrDims1 := getNrDims(inType1);
  nrDims2 := getNrDims(inType2);
  isArray1 := nrDims1 > 0;
  isArray2 := nrDims2 > 0;
  bothArrays := isArray1 and isArray2;

  (outExp, outType) := match inOp
    local
      DAE.Exp exp1,exp2;
      DAE.Type ty1,ty2, arrtp, ty;
      DAE.Dimensions dims;
      DAE.Dimension M,N1,N2,K;
      DAE.Operator newop;
      DAE.TypeSource typsrc;

    case DAE.ADD()
      algorithm
        if (bothArrays) then
          (exp1,exp2,outType) := matchTypeBothWays(inExp1,inType1,inExp2,inType2);
          outExp := DAE.BINARY(exp1, DAE.ADD(outType), exp2);
        else
          binaryArrayOpError(inExp1,inType1,inExp2,inType2,inOp,
            "\n: Addition operations involving an array and a scalar are " +
            "not valid in Modelica. Try using elementwise operator '.+'");
          fail();
        end if;
      then
        (outExp, outType);

    case DAE.SUB()
      algorithm
        if (bothArrays) then
          (exp1,exp2,outType) := matchTypeBothWays(inExp1,inType1,inExp2,inType2);
          outExp := DAE.BINARY(exp1, DAE.SUB(outType), exp2);
        else
          binaryArrayOpError(inExp1,inType1,inExp2,inType2,inOp,
            "\n: Subtraction operations involving an array and a scalar are " +
            "not valid in Modelica. Try using elementwise operator '.+'");
          fail();
        end if;
      then
        (outExp, outType);

    case DAE.DIV()
      algorithm
        if (isArray1 and not isArray2) then
          dims := getArrayTypeDims(inType1);
          arrtp := promoteLeft(inType2,dims);

          (exp1,exp2,ty1) := matchTypeBothWays(inExp1,inType1,inExp2,arrtp);

          // Create a scalar Real Type and lift it to array.
          // Necessary because even if both operands are of Integer type the result
          // should be Real type with dimensions of the input array operand.
          typsrc := Types.getTypeSource(ty1);
          ty := DAE.T_REAL({},typsrc);

          outType := promoteLeft(ty,dims);
          outExp := DAE.BINARY(exp1, DAE.DIV_ARRAY_SCALAR(outType), exp2);
        else
          binaryArrayOpError(inExp1,inType1,inExp2,inType2,inOp,
            "\n: Dividing a sclar by array or array by array is not a valid " +
            "operation in Modelica. Try using elementwise operator './'");
          fail();
        end if;
      then
        (outExp, outType);

    case DAE.POW()
      algorithm
        if (nrDims1 == 2 and not isArray2) then
          M := Types.getDimensionNth(inType1, 1);
          K := Types.getDimensionNth(inType1, 2);
          // Check if dims are equal. i.e Square Matrix
          if not(isValidMatrixMultiplyDims(M, K)) then
            binaryArrayOpError(inExp1,inType1,inExp2,inType2,inOp,
              "\n: Exponentiation involving arrays is only valid for square " +
              "matrices with integer exponents. Try using elementwise operator '.^'");
            fail();
          end if;

          try
            DAE.T_INTEGER(_,_) := inType2;
          else
            binaryArrayOpError(inExp1,inType1,inExp2,inType2,inOp,
              "\n: Exponentiation involving arrays is only valid for square " +
              "matrices with integer exponents. Try using elementwise operator '.^'");
            fail();
          end try;

          outType := inType1;
          outExp := DAE.BINARY(inExp1, DAE.POW_ARRAY_SCALAR(inType1), inExp2);
        else
          binaryArrayOpError(inExp1,inType1,inExp2,inType2,inOp,
            "\n: Exponentiation involving arrays is only valid for square " +
            "matrices with integer exponents. Try using elementwise operator '.^'");
          fail();
        end if;
      then
        (outExp, outType);


    case DAE.MUL()
      algorithm
        if (not isArray1 or not isArray2) then

          arrtp := if isArray1 then inType1 else inType2;
          dims := getArrayTypeDims(arrtp);
          //match their scalar types. For now.
          ty1 := underlyingType(inType1);
          ty2 := underlyingType(inType2);
          // TODO: one of the exps is array but its type is now simple.
          (exp1,exp2,ty) := matchTypeBothWays(inExp1,ty1,inExp2,ty2);

          outType := promoteLeft(ty,dims);
          outExp := DAE.BINARY(exp1, DAE.MUL_ARRAY_SCALAR(outType), exp2);

        elseif (nrDims1 == 1 and nrDims2 == 1) then
          {N1} := getArrayTypeDims(inType1);
          {N2} := getArrayTypeDims(inType2);
          if (not isValidMatrixMultiplyDims(N1,N2)) then
            binaryArrayOpError(inExp1,inType1,inExp2,inType2,inOp,
            "\n: Dimensions not equal for scalar product.");
            fail();
          else
            (exp1,exp2,ty) := matchTypeBothWays(inExp1,inType1,inExp2,inType2);
            outType := underlyingType(ty);
            outExp := DAE.BINARY(exp1, DAE.MUL_SCALAR_PRODUCT(outType), exp2);
          end if;

        elseif (nrDims1 == 2 and nrDims2 == 1) then
          {M,N1} := getArrayTypeDims(inType1);
          {N2} := getArrayTypeDims(inType2);
          if (not isValidMatrixMultiplyDims(N1,N2)) then
            binaryArrayOpError(inExp1,inType1,inExp2,inType2,inOp,
            "\n: Dimensions error in Matrix Vector multiplication.");
            fail();
          else
            ty1 := underlyingType(inType1);
            ty2 := underlyingType(inType2);
            // TODO: the exps are arrays but the types are now simple.
            (exp1,exp2,ty) := matchTypeBothWays(inExp1,ty1,inExp2,ty2);
            outType := promoteLeft(ty, {M});
            outExp := DAE.BINARY(exp1, DAE.MUL_MATRIX_PRODUCT(outType), exp2);
          end if;

        elseif (nrDims1 == 1 and nrDims2 == 2) then

          {N1} := getArrayTypeDims(inType1);
          {N2,M} := getArrayTypeDims(inType2);
          if (not isValidMatrixMultiplyDims(N1,N2)) then
            binaryArrayOpError(inExp1,inType1,inExp2,inType2,inOp,
            "\n: Dimensions error in Vecto Matrix multiplication.");
            fail();
          else
            ty1 := underlyingType(inType1);
            ty2 := underlyingType(inType2);
            // TODO: the exps are arrays but the types are now simple.
            (exp1,exp2,ty) := matchTypeBothWays(inExp1,ty1,inExp2,ty2);
            outType := promoteLeft(ty, {M});
            outExp := DAE.BINARY(exp1, DAE.MUL_MATRIX_PRODUCT(outType), exp2);
          end if;

        elseif (nrDims1 == 2 and nrDims2 == 2) then

          {M,N1} := getArrayTypeDims(inType1);
          {N2,K} := getArrayTypeDims(inType2);
          if (not isValidMatrixMultiplyDims(N1,N2)) then
            binaryArrayOpError(inExp1,inType1,inExp2,inType2,inOp,
            "\n: Dimensions error in Matrix Matrix multiplication.");
            fail();
          else
            ty1 := underlyingType(inType1);
            ty2 := underlyingType(inType2);
            // TODO: the exps are arrays but the types are now simple.
            (exp1,exp2,ty) := matchTypeBothWays(inExp1,ty1,inExp2,ty2);
            outType := promoteLeft(ty, {M,K});
            outExp := DAE.BINARY(exp1, DAE.MUL_MATRIX_PRODUCT(outType), exp2);
          end if;

        else
          binaryArrayOpError(inExp1,inType1,inExp2,inType2,inOp,"");
          fail();
        end if;

      then
        (outExp, outType);

    case _ guard isOpBinaryElemWise(inOp)
      algorithm
        (exp1,exp2,outType) := matchTypeBothWays(inExp1,inType1,inExp2,inType2);
        newop := Expression.setOpType(inOp, outType);
        outExp := DAE.BINARY(exp1, newop, exp2);
      then
        (outExp, outType);

    else
      algorithm
        assert(false, getInstanceName() + ": got a binary operation that is not
            handled yet");
      then
        fail();
  end match;

end checkBinaryOperationArrays;


protected function checkBinaryOperationArrays_old
  "mahge:
  Type checks binary operations involving arrays. This involves more checks than
  scalar types. All normal operations as well as element wise operations involving
  arrays are handled here."
  input DAE.Exp inExp1;
  input DAE.Type inType1;
  input DAE.Operator inOp;
  input DAE.Exp inExp2;
  input DAE.Type inType2;
  output DAE.Exp outExp;
  output DAE.Type outType;
algorithm
  (outExp,outType) := matchcontinue inOp
    local
      DAE.Exp exp1,exp2,exp;
      DAE.Type ty1,ty2, arrtp, ty;
      String e1Str, t1Str, e2Str, t2Str, s1, s2, sugg;
      Boolean isarr1,isarr2;
      DAE.Dimensions dims;
      DAE.Dimension M,N1,N2,K;
      DAE.Operator newop;
      DAE.TypeSource typsrc;


    // Adding Subtracting a scalar/array by array/scalar is not allowed.
    // N.B. Allowed only if elemwise operation
    case DAE.ADD()
      equation
        isarr1 = Types.arrayType(inType1);
        isarr2 = Types.arrayType(inType2);

        // If one of them is a Scalar.
        false = isarr1 and isarr2;

        e1Str = ExpressionDump.printExpStr(inExp1);
        t1Str = Types.unparseType(inType1);
        e2Str = ExpressionDump.printExpStr(inExp2);
        t2Str = Types.unparseType(inType2);
        sugg = "\n: Addition operations involving an array and a scalar are not valid in Modelica. Try using elementwise operator '.+'";
        s1 = "' " + e1Str + DAEDump.dumpOperatorSymbol(inOp) + e2Str + " '";
        s2 = "' " + t1Str + DAEDump.dumpOperatorString(inOp) + t2Str + " '";
        Error.addSourceMessage(Error.UNRESOLVABLE_TYPE, {s1,s2,sugg}, Absyn.dummyInfo);
      then
        fail();

    // Adding Subtracting a scalar/array by array/scalar is not allowed.
    // N.B. Allowed only if elemwise operation
    case DAE.SUB()
      equation
        isarr1 = Types.arrayType(inType1);
        isarr2 = Types.arrayType(inType2);

        // If one of them is a Scalar.
        false = isarr1 and isarr2;

        e1Str = ExpressionDump.printExpStr(inExp1);
        t1Str = Types.unparseType(inType1);
        e2Str = ExpressionDump.printExpStr(inExp2);
        t2Str = Types.unparseType(inType2);
        sugg = "\n: Subtraction operations involving an array and a scalar are not valid in Modelica. Try using elementwise operator '.-'";
        s1 = "' " + e1Str + DAEDump.dumpOperatorSymbol(inOp) + e2Str + " '";
        s2 = "' " + t1Str + DAEDump.dumpOperatorString(inOp) + t2Str + " '";
        Error.addSourceMessage(Error.UNRESOLVABLE_TYPE, {s1,s2,sugg}, Absyn.dummyInfo);
      then
        fail();

    // Dividing array by scalar. {a,b,c} / s is OK
    // But the operation should be changed to elemwise. DAE.DIV -> DIV_ARRAY_SCALAR
    // And the return type and operator types are always REAL type.
    case DAE.DIV()
      equation
        true = Types.arrayType(inType1);
        false = Types.arrayType(inType2);

        DAE.T_ARRAY(_,dims,_) = inType1;
        arrtp = Types.liftArrayListDims(inType2,dims);

        (exp1,exp2,ty1) = matchTypeBothWays(inExp1,inType1,inExp2,arrtp);

        // Create a scalar Real Type and lift it to array.
        // Necessary because even if both operands are of Integer type the result
        // should be Real type with dimensions of the input array operand.
        typsrc = Types.getTypeSource(ty1);
        ty = DAE.T_REAL({},typsrc);
        arrtp = Types.liftArrayListDims(ty,dims);

        newop = Expression.setOpType(inOp, arrtp);

        newop = DAE.DIV_ARRAY_SCALAR(arrtp);
        exp = DAE.BINARY(exp1, newop, exp2);

      then
        (exp,arrtp);

    // Dividing scalar or array by array. s / {a,b,c} or {a,b,c} / {a,b,c} is not allowed.
    // i.e. if the case above failed nothing else is allowed for DAE.DIV()
    case DAE.DIV()
      equation
        e1Str = ExpressionDump.printExpStr(inExp1);
        t1Str = Types.unparseType(inType1);
        e2Str = ExpressionDump.printExpStr(inExp2);
        t2Str = Types.unparseType(inType2);
        sugg = "\n: Dividing a sclar by array or array by array is not a valid operation in Modelica. Try using elementwise operator './'";
        s1 = "' " + e1Str + DAEDump.dumpOperatorSymbol(inOp) + e2Str + " '";
        s2 = "' " + t1Str + DAEDump.dumpOperatorString(inOp) + t2Str + " '";
        Error.addSourceMessage(Error.UNRESOLVABLE_TYPE, {s1,s2,sugg}, Absyn.dummyInfo);
      then
        fail();

    // Exponentiation of array by scalar. A[:,:]^s is OK only if A is a square matrix and s is an integer type.
    // The operation should be changed to POW_ARRAY_SCALAR.
    case DAE.POW()
      equation

        DAE.T_INTEGER(_,_) = inType2;

        2 = getArrayNumberOfDimensions(inType1);
        M = Types.getDimensionNth(inType1, 1);
        K = Types.getDimensionNth(inType1, 2);
        // Check if dims are equal. i.e Square Matrix
        true = isValidMatrixMultiplyDims(M, K);

        newop = Expression.setOpType(inOp, inType1);

        newop = DAE.POW_ARRAY_SCALAR(inType1);
        exp = DAE.BINARY(inExp1, newop, inExp2);

      then
        (exp,inType1);

    // Exponentiation involving and array is invlaid.
    // s ^ {a,b,c}, {a,b,c} ^ s, {a,b,c} ^ {a,b,c} are all invalid.
    // N.B. Allowed only if elemwise operation
    case DAE.POW()
      equation
        e1Str = ExpressionDump.printExpStr(inExp1);
        t1Str = Types.unparseType(inType1);
        e2Str = ExpressionDump.printExpStr(inExp2);
        t2Str = Types.unparseType(inType2);
        sugg = "\n: Exponentiation involving arrays is only valid for square matrices with integer exponents. Try using elementwise operator '.^'";
        s1 = "' " + e1Str + DAEDump.dumpOperatorSymbol(inOp) + e2Str + " '";
        s2 = "' " + t1Str + DAEDump.dumpOperatorString(inOp) + t2Str + " '";
        Error.addSourceMessage(Error.UNRESOLVABLE_TYPE, {s1,s2,sugg}, Absyn.dummyInfo);
      then
        fail();


    // Multiplication involving an array and scalar is fine.
    case DAE.MUL()
      equation
        isarr1 = Types.arrayType(inType1);
        isarr2 = Types.arrayType(inType2);

        // If one of them is a Scalar.
        false = isarr1 and isarr2;

        // Get the dims from the array operand
        arrtp = if isarr1 then inType1 else inType2;
        DAE.T_ARRAY(_,dims,_) = arrtp;

        //match their scalar types
        ty1 = Types.arrayElementType(inType1);
        ty2 = Types.arrayElementType(inType2);
        (exp1,exp2,ty1) = matchTypeBothWays(inExp1,ty1,inExp2,ty2);

        // Create the resulting array and exptype
        ty = Types.liftArrayListDims(ty1,dims);
        newop = DAE.MUL_ARRAY_SCALAR(ty);
        exp = DAE.BINARY(exp1, newop, exp2);

      then
        (exp,ty);


    /********************************************************************/
    // Handling of Matrix/Vector operations.
    /********************************************************************/

    // Multiplication of two vectors. Vector[n]*Vector[n] = Scalar
    // Resolves to Scalar product. DAE.MUL_SCALAR_PRODUCT
    case DAE.MUL()
      equation

        1 = getArrayNumberOfDimensions(inType1);
        1 = getArrayNumberOfDimensions(inType1);

        (exp1,exp2,ty1) = matchTypeBothWays(inExp1,inType1,inExp2,inType2);

        ty = Types.arrayElementType(ty1);

        newop = DAE.MUL_SCALAR_PRODUCT(ty);
        exp = DAE.BINARY(exp1, newop, exp2);

      then
        (exp,ty);

    // Multiplication of Matrix by vector. Matrix[M,N1] * Vector[N2] = Vector[M]
    // Resolves to Matrix multiplication. DAE.MUL_MATRIX_PRODUCT
    case DAE.MUL()
      equation

        2 = getArrayNumberOfDimensions(inType1);
        1 = getArrayNumberOfDimensions(inType2);

        // Check if dimensions are valid
        M = Types.getDimensionNth(inType1, 1);
        N1 = Types.getDimensionNth(inType1, 2);
        N2 = Types.getDimensionNth(inType2, 1);
        true = isValidMatrixMultiplyDims(N1, N2);

        ty1 = Types.arrayElementType(inType1);
        ty2 = Types.arrayElementType(inType2);

        // Is this OK? using the original exps with the element types of the arrays?
        (exp1,exp2,ty) = matchTypeBothWays(inExp1,ty1,inExp2,ty2);

        // Perpare the resulting Vector,. Vector[M]
        ty = Types.liftArray(ty, M);

        newop = DAE.MUL_MATRIX_PRODUCT(ty);
        exp = DAE.BINARY(exp1, newop, exp2);

      then
        (exp,ty);

    // Multiplication of Vector by Matrix.  Vector[N1] * Matrix[N2,M] = Vector[M]
    // Resolves to Matrix multiplication.
    case DAE.MUL()
      equation

        1 = getArrayNumberOfDimensions(inType1);
        2 = getArrayNumberOfDimensions(inType2);

        // Check if dimensions are valid
        N1 = Types.getDimensionNth(inType1, 1);
        N2 = Types.getDimensionNth(inType2, 1);
        M = Types.getDimensionNth(inType2, 2);
        true = isValidMatrixMultiplyDims(N1, N2);

        ty1 = Types.arrayElementType(inType1);
        ty2 = Types.arrayElementType(inType2);

        // Is this OK? using the original exps with the element types of the arrays?
        (exp1,exp2,ty) = matchTypeBothWays(inExp1,ty1,inExp2,ty2);

        // Perpare the resulting Vector,. Vector[M]
        ty = Types.liftArray(ty, M);

        newop = DAE.MUL_MATRIX_PRODUCT(ty);
        exp = DAE.BINARY(exp1, newop, exp2);

      then
        (exp,ty);


    // Multiplication of two Matrices. Matrix[M,N1] * Matrix[N2,K] = Matrix[M, K]
    // Resolves to Matrix multiplication.
    case DAE.MUL()
      equation

        2 = getArrayNumberOfDimensions(inType1);
        2 = getArrayNumberOfDimensions(inType2);

        // Check if dimensions are valid
        M = Types.getDimensionNth(inType1, 1);
        N1 = Types.getDimensionNth(inType1, 2);
        N2 = Types.getDimensionNth(inType2, 1);
        K = Types.getDimensionNth(inType2, 2);
        true = isValidMatrixMultiplyDims(N1, N2);

        // We can't use this here because the dimensions do not exactly match.
        // do it manually here.
        // (exp1,exp2,ty1) = matchTypeBothWays(inExp1,inType1,inExp2,inType2);

        ty1 = Types.arrayElementType(inType1);
        ty2 = Types.arrayElementType(inType2);

        // Is this OK? using the original exps with the element types of the arrays?
        (exp1,exp2,ty) = matchTypeBothWays(inExp1,ty1,inExp2,ty2);

        // Perpare the resulting Matrix type,. Matrix[M, K]
        ty = Types.liftArrayListDims(ty, {M, K});

        newop = DAE.MUL_MATRIX_PRODUCT(ty);
        exp = DAE.BINARY(exp1, newop, exp2);

      then
        (exp,ty);

    // Handling of Matrix/Vector operations ends here.
    /********************************************************************/



    // Multiplying array by array. a[2,2,...] * b[2,2,...] is not allowed.
    // i.e. if the cases above failed, which means it is not a Vector/Matrix operation.
    // nothing else is allowed for DAE.MUL().
    // N.B. Allowed only if elementwise oepration
    case DAE.MUL()
      equation
        e1Str = ExpressionDump.printExpStr(inExp1);
        t1Str = Types.unparseType(inType1);
        e2Str = ExpressionDump.printExpStr(inExp2);
        t2Str = Types.unparseType(inType2);
        s1 = "' " + e1Str + DAEDump.dumpOperatorSymbol(inOp) + e2Str + " '";
        s2 = "' " + t1Str + DAEDump.dumpOperatorString(inOp) + t2Str + " '";
        Error.addSourceMessage(Error.UNRESOLVABLE_TYPE, {s1,s2,t1Str}, Absyn.dummyInfo);
      then
        fail();


    /********************************************************************/
    // Everything else is fine as long as the types of the operands match.
    // This include all Element wise binary oeprations!!!
    /********************************************************************/

    // Operations involving an array and a scalar
    // If there is no specific handling for them
    // (i.e. not handled by cases above.) we can assume
    // that they return a value with same dims as the array operand.
    case _
      equation

        isarr1 = Types.arrayType(inType1);
        isarr2 = Types.arrayType(inType2);

        // If one of them is a Scalar.
        false = isarr1 and isarr2;

        // Get the dims from the array operand
        arrtp = if isarr1 then inType1 else inType2;
        DAE.T_ARRAY(_,dims,_) = arrtp;

        //match their scalar types
        ty1 = Types.arrayElementType(inType1);
        ty2 = Types.arrayElementType(inType2);
        (exp1,exp2,ty1) = matchTypeBothWays(inExp1,ty1,inExp2,ty2);

        // Create the resulting array and exptype
        ty = Types.liftArrayListDims(ty1,dims);
        newop = Expression.setOpType(inOp, ty);
        exp = DAE.BINARY(exp1, newop, exp2);
      then
        (exp,ty);

    // Both operands are arrays
    case _
      equation

        // true = Types.arrayType(inType1);
        // true = Types.arrayType(inType2);

        (exp1,exp2,ty1) = matchTypeBothWays(inExp1,inType1,inExp2,inType2);
        newop = Expression.setOpType(inOp, ty1);
        exp = DAE.BINARY(exp1, newop, exp2);
      then
        (exp,ty1);

    // Failure
    else
      equation
        e1Str = ExpressionDump.printExpStr(inExp1);
        t1Str = Types.unparseType(inType1);
        e2Str = ExpressionDump.printExpStr(inExp2);
        t2Str = Types.unparseType(inType2);
        s1 = "' " + e1Str + DAEDump.dumpOperatorSymbol(inOp) + e2Str + " '";
        s2 = "' " + t1Str + DAEDump.dumpOperatorString(inOp) + t2Str + " '";
        Error.addSourceMessage(Error.UNRESOLVABLE_TYPE, {s1,s2,t1Str}, Absyn.dummyInfo);
        true = Flags.isSet(Flags.FAILTRACE);
        Debug.traceln("- " + getInstanceName() + " failed with type mismatch: " + t1Str + " tys: " + t2Str);
      then
        fail();

  end matchcontinue;
end checkBinaryOperationArrays_old;


// ************************************************************** //
//   END: Operator typing helper functions
// ************************************************************** //





//// ************************************************************** //
////   BEGIN: TypeCall helper functions
//// ************************************************************** //
//
//
//public function matchCallArgs
//"@mahge:
//  matches given call args with the expected or formal arguments for a function.
//  if vectorization dimension (inVectDims) is given (is not empty) then the function
//  works with vectorization mode.
//  otherwise no vectorization will be done.
//
//  However if matching fails in no vect. mode due to dim mismatch then
//  a vect dim will be returned from  NFTypeCheck.matchCallArgs and this
//  function will start all over again with the new vect dimension."
//
//  input list<DAE.Exp> inArgs;
//  input list<DAE.Type> inArgTypes;
//  input list<DAE.Type> inExpectedTypes;
//  input DAE.Dimensions inVectDims;
//  output list<DAE.Exp> outFixedArgs;
//  output DAE.Dimensions outVectDims;
//algorithm
//  (outFixedArgs, outVectDims):=
//  matchcontinue (inArgs,inArgTypes,inExpectedTypes, inVectDims)
//    local
//      DAE.Exp e,e_1;
//      list<DAE.Exp> restargs, fixedArgs;
//      DAE.Type t1,t2;
//      list<DAE.Type> restinty,restexpcty;
//      DAE.Dimensions dims1, dims2;
//      String e1Str, t1Str, t2Str, s1;
//
//    case ({},{},{},_) then ({}, inVectDims);
//
//    // No vectorization mode.
//    // If things continue to match with no vect.
//    // Then all is good.
//    case (e::restargs, (t1 :: restinty), (t2 :: restexpcty), {})
//      equation
//        (e_1, {}) = matchCallArg(e,t1,t2,{});
//
//        (fixedArgs, {}) = matchCallArgs(restargs, restinty, restexpcty, {});
//      then
//        (e_1::fixedArgs, {});
//
//    // No vectorization mode.
//    // If argument failed to match not because of dim mismatch
//    // but due to actuall type mismatch then it is an invalid call and we fail here.
//    case (e::_, (t1 :: _), (t2 :: _), {})
//      equation
//        failure((_,_) = matchCallArg(e,t1,t2,{}));
//
//        e1Str = ExpressionDump.printExpStr(e);
//        t1Str = Types.unparseType(t1);
//        t2Str = Types.unparseType(t2);
//        s1 = "Failed to match or convert '" + e1Str + "' of type '" + t1Str +
//             "' to type '" + t2Str + "'";
//        Error.addSourceMessage(Error.INTERNAL_ERROR, {s1}, Absyn.dummyInfo);
//        true = Flags.isSet(Flags.FAILTRACE);
//        Debug.traceln("- NFTypeCheck.matchCallArgs failed with type mismatch: " + t1Str + " tys: " + t2Str);
//      then
//        fail();
//
//    // No -> Yes vectorization mode.
//    // If argument fails to match due to dim mistmatch. then we
//    // have our vect. dim and we start from the begining.
//    case (e::_, (t1 :: _), (t2 :: _), {})
//      equation
//        (_, dims1) = matchCallArg(e,t1,t2,{});
//
//        // This is just to be realllly sure. The cases above actually make sure of it.
//        false = Expression.dimsEqual(dims1, {});
//
//        // Start from the first arg. This time with Vectorization.
//        (fixedArgs, dims2) = matchCallArgs(inArgs,inArgTypes,inExpectedTypes, dims1);
//      then
//        (fixedArgs, dims2);
//
//    // Vectorization mode.
//    case (e::restargs, (t1 :: restinty), (t2 :: restexpcty), dims1)
//      equation
//        false = Expression.dimsEqual(dims1, {});
//        (e_1, dims1) = matchCallArg(e,t1,t2,dims1);
//        (fixedArgs, dims1) = matchCallArgs(restargs, restinty, restexpcty, dims1);
//      then
//        (e_1::fixedArgs, dims1);
//
//
//
//    case (_::_,(_ :: _),(_ :: _), _)
//      equation
//        true = Flags.isSet(Flags.FAILTRACE);
//        Debug.trace("- NFTypeCheck.matchCallArgs failed\n");
//      then
//        fail();
//  end matchcontinue;
//end matchCallArgs;
//
//
//public function matchCallArg
//"@mahge:
//  matches a given call arg with the expected or formal argument for a function.
//  if vectorization dimension (inVectDims) is given (is not empty) then the function
//  works with vectorization mode.
//  otherwise no vectorization will be done.
//
//  However if matching fails in no vect. mode due to dim mismatch then
//  it will try to see if vectoriztion is possible. If so the vectorization dim is
//  returned to NFTypeCheck.matchCallArg so that it can start matching from the begining
//  with the new vect dim."
//
//  input DAE.Exp inArg;
//  input DAE.Type inArgType;
//  input DAE.Type inExpectedType;
//  input DAE.Dimensions inVectDims;
//  output DAE.Exp outArg;
//  output DAE.Dimensions outVectDims;
//algorithm
//  (outArg, outVectDims) := matchcontinue (inArg,inArgType,inExpectedType,inVectDims)
//    local
//      DAE.Exp e,e_1;
//      DAE.Type e_type,expected_type;
//      String e1Str, t1Str, t2Str, s1;
//      DAE.Dimensions dims1, dims2, foreachdim;
//
//
//    // No vectorization mode.
//    // Types match (i.e. dims match exactly). Then all is good
//    case (e,e_type,expected_type, {})
//      equation
//        // Of course matchtype will make sure of this
//        // but this is faster.
//        dims1 = Types.getDimensions(e_type);
//        dims2 = Types.getDimensions(expected_type);
//        true = Expression.dimsEqual(dims1, dims2);
//
//        (e_1,_) = Types.matchType(e, e_type, expected_type, true);
//      then
//        (e_1, {});
//
//
//    // No vectorization mode.
//    // If it failed NOT because of dim mismatch but because
//    // of actuall type mismatch then fail here.
//    case (_,e_type,expected_type, {})
//      equation
//        dims1 = Types.getDimensions(e_type);
//        dims2 = Types.getDimensions(expected_type);
//        true = Expression.dimsEqual(dims1, dims2);
//      then
//        fail();
//
//    // No Vect. -> Vectorization mode.
//    // We found a dim mistmatch. Try vectorizing. If vectorizing
//    // matches, then this is our vectoriztion dimension.
//    // N.B. We still have to start matching again from the first arg
//    // with the new vectorization dimension.
//    case (e,e_type,expected_type, {})
//      equation
//        dims1 = Types.getDimensions(e_type);
//        dims2 = Types.getDimensions(expected_type);
//
//        false = Expression.dimsEqual(dims1, dims2);
//
//        foreachdim = findVectorizationDim(dims1,dims2);
//
//      then
//        (e, foreachdim);
//
//
//    // IN Vectorization mode!!!.
//    case (e,e_type,expected_type, foreachdim)
//      equation
//        e_1 = checkVectorization(e,e_type,expected_type,foreachdim);
//      then
//        (e_1, foreachdim);
//
//
//    case (e,e_type,expected_type, _)
//      equation
//        e1Str = ExpressionDump.printExpStr(e);
//        t1Str = Types.unparseType(e_type);
//        t2Str = Types.unparseType(expected_type);
//        s1 = "Failed to match or convert '" + e1Str + "' of type '" + t1Str +
//             "' to type '" + t2Str + "'";
//        Error.addSourceMessage(Error.INTERNAL_ERROR, {s1}, Absyn.dummyInfo);
//        true = Flags.isSet(Flags.FAILTRACE);
//        Debug.traceln("- NFTypeCheck.matchCallArg failed with type mismatch: " + t1Str + " tys: " + t2Str);
//      then
//        fail();
//  end matchcontinue;
//end matchCallArg;
//
//
//protected function checkVectorization
//"@mahge:
//  checks if it is possible to vectorize a given argument to the
//  expected or formal argument with the given vectorization dim.
//  e.g. inForeachDim=[3,2]
//       function F(input Integer[2]);
//
//       Integer a[2,3,2], b[2,2,2],s;
//
//       a is vectorizable with [3,2] => a[1]), a[2]
//       b is not vectorizable with [3,2]
//       s is vectorizable with [3,2] => {{s,s},{s,s},{s,s}}
//
//  N.B. The vectoriztion dim came from the first arg mismatch in
//  NFTypeCheck.matchCallArg and all susequent args shoudl be vectorizable
//  with that dim. This function checks that.
//  "
//  input DAE.Exp inArg;
//  input DAE.Type inArgType;
//  input DAE.Type inExpectedType;
//  input DAE.Dimensions inForeachDim;
//  output DAE.Exp outArg;
//algorithm
//  outArg := matchcontinue (inArg,inArgType,inExpectedType,inForeachDim)
//    local
//      DAE.Exp outExp;
//      DAE.Dimensions expectedDims, argDims;
//      String e1Str, t1Str, t2Str, s1;
//      DAE.Type expcType;
//
//    // if types match (which also means dims match exactly).
//    // Then we have to change the given argument to an array of
//    // the vect. dim to have a 'foreach' argument
//    case(_,_,_,_)
//      equation
//        // Of course matchtype will make sure of this
//        // but this is faster.
//        argDims = Types.getDimensions(inArgType);
//        expectedDims = Types.getDimensions(inExpectedType);
//        true = Expression.dimsEqual(argDims, expectedDims);
//
//        (outExp,_) = Types.matchType(inArg, inArgType, inExpectedType, false);
//
//        // create the array from the given arg to match the vectorization
//        outExp = Expression.arrayFill(inForeachDim,outExp);
//      then
//        outExp;
//
//    // if dims don't match exactly. Then the given argument
//    // must have the same dimension as our vecorization or 'foreach' dimension.
//    // And the expected type will be lifeted to the 'foreach' dim and then
//    // matched with the given argument
//    case(_,_,_,_)
//      equation
//
//        argDims = Types.getDimensions(inArgType);
//
//        // lift the expected type by 'foreach' dims
//        expcType = Types.liftArrayListDims(inExpectedType,inForeachDim);
//
//        // Now the given type and the expected type must have the
//        // same dimesions. Otherwise vectorization is not possible.
//        expectedDims = Types.getDimensions(expcType);
//        true = Expression.dimsEqual(argDims, expectedDims);
//
//        (outExp,_) = Types.matchType(inArg, inArgType, expcType, false);
//      then
//        outExp;
//
//    else
//      equation
//        argDims = Types.getDimensions(inArgType);
//        expectedDims = Types.getDimensions(inExpectedType);
//
//        expectedDims = listAppend(inForeachDim,expectedDims);
//
//        e1Str = ExpressionDump.printExpStr(inArg);
//        t1Str = Types.unparseType(inArgType);
//        t2Str = Types.unparseType(inExpectedType);
//        s1 = "Vectorization can not continue matching '" + e1Str + "' of type '" + t1Str +
//             "' to type '" + t2Str + "'. Expected dimensions [" +
//             ExpressionDump.printListStr(expectedDims,ExpressionDump.dimensionString,",") + "], found [" +
//             ExpressionDump.printListStr(argDims,ExpressionDump.dimensionString,",") + "]";
//
//        Error.addSourceMessage(Error.INTERNAL_ERROR, {s1}, Absyn.dummyInfo);
//        true = Flags.isSet(Flags.FAILTRACE);
//        Debug.traceln("- NFTypeCheck.checkVectorization failed ");
//      then
//        fail();
//
//   end matchcontinue;
//
//end checkVectorization;
//
//
//public function findVectorizationDim
//"@mahge:
// This function basically finds the diff between two dims. The resulting dimension
// is used for vectorizing calls.
//
// e.g. dim1=[2,3,4,2]  dim2=[4,2], findVectorizationDim(dim1,dim2) => [2,3]
//      dim1=[2,3,4,2]  dim2=[3,4,2], findVectorizationDim(dim1,dim2) => [2]
//      dim1=[2,3,4,2]  dim2=[4,3], fail
// "
//  input DAE.Dimensions inGivenDims;
//  input DAE.Dimensions inExpectedDims;
//  output DAE.Dimensions outVectDims;
//algorithm
//  outVectDims := matchcontinue(inGivenDims, inExpectedDims)
//    local
//      DAE.Dimensions dims1;
//      DAE.Dimension dim1;
//
//    case(_, {}) then inGivenDims;
//
//    case(_, _)
//      equation
//        true = Expression.dimsEqual(inGivenDims, inExpectedDims);
//      then
//        {};
//
//    case(dim1::dims1, _)
//      equation
//        true = listLength(inGivenDims) > listLength(inExpectedDims);
//        dims1 = findVectorizationDim(dims1,inExpectedDims);
//      then
//        dim1::dims1;
//
//    case(_::_, _)
//      equation
//        true = Flags.isSet(Flags.FAILTRACE);
//        Debug.traceln("- NFTypeCheck.findVectorizationDim failed with dimensions: [" +
//         ExpressionDump.printListStr(inGivenDims,ExpressionDump.dimensionString,",") + "] vs [" +
//         ExpressionDump.printListStr(inExpectedDims,ExpressionDump.dimensionString,",") + "].");
//      then
//        fail();
//
//  end matchcontinue;
//
//end findVectorizationDim;
//
//
//public function makeCallReturnType
//"@mahge:
//   makes the return type for function.
//   i.e if a list of types is given then it is a tuple ret function.
// "
//  input list<DAE.Type> inTypeLst;
//  output DAE.Type outType;
//  output Boolean outBoolean;
//algorithm
//  (outType,outBoolean) := match (inTypeLst)
//    local
//      DAE.Type ty;
//
//    case {} then (DAE.T_NORETCALL(DAE.emptyTypeSource), false);
//
//    case {ty} then (ty, false);
//
//    else  (DAE.T_TUPLE(inTypeLst,NONE(),DAE.emptyTypeSource), true);
//
//  end match;
//end makeCallReturnType;
//
//
//
//public function vectorizeCall
//"@mahge:
//   Vectorizes calls. Most of the work is done
//   vectorizeCall2.
//   This function get a list of functions with each arg
//   subscripted from vectorizeCall2. e.g. {F(a[1,1]),F(a[1,2]),F(a[2,1]),F(a[2,2])}
//   The it converts the list to an array of 'inForEachdim' dims using
//   Expression.listToArray. i.e.
//   {F(a[1,1]),F(a[1,2]),F(a[2,1]),F(a[2,2])} with vec. dim [2,2] will be
//   {{F(a[1,1]),F(a[1,2])}, {F(a[2,1])F(a[2,2])}}
//
// "
//  input Absyn.Path inFnName;
//  input list<DAE.Exp> inArgs;
//  input DAE.CallAttributes inAttrs;
//  input DAE.Type inRetType;
//  input DAE.Dimensions inForEachdim;
//  output DAE.Exp outExp;
//  output DAE.Type outType;
//algorithm
//  (outExp,outType) := matchcontinue (inFnName,inArgs,inAttrs,inRetType,inForEachdim)
//    local
//      list<DAE.Exp> callLst;
//      DAE.Exp callArr;
//      DAE.Type outtype;
//
//
//    // If no 'forEachdim' then no vectorization
//    case(_, _, _, _, {}) then (DAE.CALL(inFnName, inArgs, inAttrs), inRetType);
//
//
//    case(_, _::_, _, _, _)
//      equation
//        // Get the call list with args subscripted for each value in 'foreaach' dim.
//        callLst = vectorizeCall2(inFnName, inArgs, inAttrs, inForEachdim, {});
//
//        // Create the array of calls from the list
//        callArr = Expression.listToArray(callLst,inForEachdim);
//
//        // lift the retType to 'forEachDim' dims
//        outtype = Types.liftArrayListDims(inRetType, inForEachdim);
//      then
//        (callArr, outtype);
//
//    else
//      equation
//        Error.addMessage(Error.INTERNAL_ERROR, {"NFTypeCheck.vectorizeCall failed."});
//      then
//        fail();
//
//  end matchcontinue;
//end vectorizeCall;
//
//
//public function vectorizeCall2
//"@mahge:
//   Vectorizes calls. This function takes a list of args for a function
//   and a vectorization dim. then it subscripts the args for each idex
//   of the vec. dim and creates a function call for each subscripted
//   arg list. Then retuns the list of functions.
//   e.g.
//   for argLst ( a, {{b,b,b},{c,c,c}} ) and functionname F with vect. dim of [2,3]
//   this function creates the list
//
//   {F(a[1,1],b), F(a[1,2],b), F(a[1,3],b), F(a[2,1],c), F(a[2,2],c), F(a[2,3],c)}
// "
//  input Absyn.Path inFnName;
//  input list<DAE.Exp> inArgs;
//  input DAE.CallAttributes inAttrs;
//  input DAE.Dimensions inDims;
//  input list<DAE.Exp> inAccumCalls;
//  output list<DAE.Exp> outAccumCalls;
//algorithm
//  outAccumCalls := matchcontinue(inFnName, inArgs, inAttrs, inDims, inAccumCalls)
//    local
//      DAE.Dimension dim;
//      DAE.Dimensions dims;
//      DAE.Exp idx;
//      list<DAE.Exp> calls, subedargs;
//
//    case (_, _, _, {}, _) then DAE.CALL(inFnName, inArgs, inAttrs) :: inAccumCalls;
//
//    case (_, _, _, dim :: dims, _)
//      equation
//        (idx, dim) = getNextIndex(dim);
//
//        subedargs = List.map1(inArgs, Expression.subscriptExp, {DAE.INDEX(idx)});
//
//        calls = vectorizeCall2(inFnName, subedargs, inAttrs, dims, inAccumCalls);
//        calls = vectorizeCall2(inFnName, inArgs, inAttrs, dim :: dims, calls);
//      then
//        calls;
//
//    else inAccumCalls;
//
//  end matchcontinue;
//end vectorizeCall2;
//
//protected function getNextIndex
//  "Returns the next index given a dimension, and updates the dimension. Fails
//  when there are no indices left."
//  input DAE.Dimension inDim;
//  output DAE.Exp outNextIndex;
//  output DAE.Dimension outDim;
//algorithm
//  (outNextIndex, outDim) := match(inDim)
//    local
//      Integer new_idx, dim_size;
//      Absyn.Path p, ep;
//      String l;
//      list<String> l_rest;
//
//    case DAE.DIM_INTEGER(integer = 0) then fail();
//    case DAE.DIM_ENUM(size = 0) then fail();
//
//    case DAE.DIM_INTEGER(integer = new_idx)
//      equation
//        dim_size = new_idx - 1;
//      then
//        (DAE.ICONST(new_idx), DAE.DIM_INTEGER(dim_size));
//
//    // Assumes that the enum has been reversed with reverseEnumType.
//    case DAE.DIM_ENUM(p, l :: l_rest, new_idx)
//      equation
//        ep = Absyn.joinPaths(p, Absyn.IDENT(l));
//        dim_size = new_idx - 1;
//      then
//        (DAE.ENUM_LITERAL(ep, new_idx), DAE.DIM_ENUM(p, l_rest, dim_size));
//  end match;
//end getNextIndex;


// ************************************************************** //
//   END: TypeCall helper functions
// ************************************************************** //

function matchTypeBothWays
  "mahge:
  Tries to match to types. First by converting the 2nd one to the 1st.
  if not possible then tries to convert the 1st to the 2nd."
  input output DAE.Exp exp1;
  input DAE.Type type1;
  input output DAE.Exp exp2;
  input DAE.Type type2;
  output DAE.Type matchedType;
algorithm
  try
    (exp2, matchedType) := Types.matchType(exp2, type2, type1, true);
  else
    (exp1, matchedType) := Types.matchType(exp1, type1, type2, true);
  end try;
end matchTypeBothWays;


public function isInteger
  input DAE.Type inType;
  output Boolean b;
algorithm
  b := match(inType)
    case DAE.T_INTEGER() then true;
    else false;
  end match;
end isInteger;

public function isReal
  input DAE.Type inType;
  output Boolean b;
algorithm
  b := match(inType)
    case DAE.T_REAL() then true;
    else false;
  end match;
end isReal;

public function isBoolean
  input DAE.Type inType;
  output Boolean b;
algorithm
  b := match(inType)
    case DAE.T_BOOL() then true;
    else false;
  end match;
end isBoolean;

public function isEnum
  input DAE.Type inType;
  output Boolean b;
algorithm
  b := match(inType)
    case DAE.T_ENUMERATION() then true;
    else false;
  end match;
end isEnum;

function isNumeric
  input DAE.Type inType;
  output Boolean b;
algorithm
  b := isReal(inType) or isInteger(inType);
end isNumeric;

protected function getArrayTypeDims
"This will fail if type is not array type.
Use in places where only arrays are expected"
  input DAE.Type inType;
  output DAE.Dimensions outDims;
algorithm
  outDims := match (inType)
    case DAE.T_ARRAY() then inType.dims;
    case DAE.T_FUNCTION() then getArrayTypeDims(inType.funcResultType);
    else fail();
  end match;
end getArrayTypeDims;

public function getTypeDims
"This will NOT fail if type is not array type."
  input DAE.Type inType;
  output DAE.Dimensions outDims;
algorithm
  outDims := match (inType)
    case DAE.T_ARRAY() then inType.dims;
    case DAE.T_FUNCTION() then getTypeDims(inType.funcResultType);
    else {};
  end match;
end getTypeDims;

public function getNrDims
  input DAE.Type inType;
  output Integer outNrDims;
algorithm
  outNrDims := match (inType)
    case DAE.T_ARRAY() then listLength(inType.dims);
    case DAE.T_FUNCTION() then getNrDims(inType.funcResultType);
    else 0;
  end match;
end getNrDims;

public function underlyingType
  input DAE.Type inType;
  output DAE.Type outType;
algorithm
  outType := match(inType)
    case DAE.T_ARRAY() then inType.ty;
    case DAE.T_FUNCTION() then underlyingType(inType.funcResultType);
    else inType;
  end match;
end underlyingType;

protected function promoteLeft
  input DAE.Type inType;
  input DAE.Dimensions inDims;
  output DAE.Type outType;
algorithm
  outType := match(inType)
    case DAE.T_ARRAY() then DAE.T_ARRAY(inType.ty, listAppend(inType.dims,inDims), inType.source);
    else DAE.T_ARRAY(inType, inDims, Types.getTypeSource(inType));
  end match;
end promoteLeft;

function applySubsToDims
  input list<DAE.Dimension> inDims;
  input list<DAE.Subscript> inSubs;
  output list<DAE.Dimension> outDims = {};
protected
  DAE.Dimension dim;
  list<DAE.Dimension> dims1, dims2, slicedims;
  DAE.Type baseTy, ixty;
algorithm
  dims1 := inDims;
  dims2 := {};

  for sub in inSubs loop
    _ := match sub
      case DAE.INDEX()
        algorithm
          ixty := Expression.typeof(sub.exp);
          slicedims := getTypeDims(ixty);
          if listLength(slicedims) > 0 then
            assert(listLength(slicedims) == 1,
              getInstanceName() + " failed. Got a slice with more than one dim?");
            _::dims1 := dims1;
            {dim} := slicedims;
            outDims := dim::outDims;
          end if;
        then
          ();

      case DAE.WHOLEDIM()
        algorithm
          dim::dims1 := dims1;
          outDims := dim::outDims;
        then
          ();
    end match;
  end for;
end applySubsToDims;

protected function isOpBinaryElemWise
  input DAE.Operator inOperator;
  output Boolean is;
algorithm
  is := match(inOperator)
    case DAE.ADD_ARR() then true;
    case DAE.SUB_ARR() then true;
    case DAE.MUL_ARR() then true;
    case DAE.DIV_ARR() then true;
    case DAE.POW_ARR2() then true;
    else false;
  end match;
end isOpBinaryElemWise;

protected function checkValidNumericTypesForOp
"  TODO: update me.
  @mahge:
  Helper function for Check*Operator functions.
  Checks if both operands are Numeric types for all operators except Addition.
  Which can also work on Strings and maybe Booleans??.
  Written separatly because it needs to print an error."
  input DAE.Type type1;
  input DAE.Type type2;
  input DAE.Operator operator;
  input Boolean printError;
  output Boolean isValid;
algorithm
  isValid := match operator
    local
      String ty1_str, ty2_str, op_str;

    case DAE.ADD() then true;

    case _ guard Types.isNumericType(type1) and Types.isNumericType(type2) then true;

    else
      algorithm
        if printError then
          ty1_str := Types.unparseTypeNoAttr(type1);
          ty2_str := Types.unparseTypeNoAttr(type2);
          op_str := DAEDump.dumpOperatorString(operator);
          Error.addSourceMessage(Error.FOUND_NON_NUMERIC_TYPES,
            {op_str, ty1_str, ty2_str}, Absyn.dummyInfo);
        end if;
      then
        false;
  end match;
end checkValidNumericTypesForOp;

protected function getArrayNumberOfDimensions
"TODO: remove me. Use getNrDims"
  input DAE.Type inType;
  output Integer outDim;
algorithm
  outDim := match (inType)
    local
      Integer ns;
      DAE.Type t;
      DAE.Dimensions dims;

    case DAE.T_ARRAY(ty = t, dims = dims)
      equation
        // TODO: we shouldn't allow T_ARRAY(T_ARRAY(),_,_) structures anymore
        // Make sure it gets caught.
        ns = getArrayNumberOfDimensions(t) + listLength(dims);
      then
        ns;

    case DAE.T_FUNCTION() then getArrayNumberOfDimensions(inType.funcResultType);

    else 0;

  end match;
end getArrayNumberOfDimensions;

protected function isValidMatrixMultiplyDims
" TODO: update me.
  @mahge:
  Checks if two dimensions are equal, which is a prerequisite for Matrix/Vector
  multiplication."
  input DAE.Dimension dim1;
  input DAE.Dimension dim2;
  output Boolean res;
algorithm
  res := matchcontinue(dim1, dim2)
    local
      String msg;
    // The dimensions are both known and equal.
    case (_, _)
      equation
        true = Expression.dimensionsKnownAndEqual(dim1, dim2);
      then
        true;
    // If checkModel is used we might get unknown dimensions. So use
    // dimensionsEqual instead, which matches anything against DIM_UNKNOWN.
    case (_, _)
      equation
        true = Flags.getConfigBool(Flags.CHECK_MODEL);
        true = Expression.dimensionsEqual(dim1, dim2);
      then
        true;
    case (_, _)
      equation
        msg = "Dimension mismatch in Vector/Matrix multiplication operation: " +
              ExpressionDump.dimensionString(dim1) + "x" + ExpressionDump.dimensionString(dim2);
        Error.addSourceMessage(Error.COMPILER_ERROR, {msg}, Absyn.dummyInfo);
      then false;
  end matchcontinue;
end isValidMatrixMultiplyDims;

protected function binaryArrayOpError
  input DAE.Exp inExp1;
  input DAE.Type inType1;
  input DAE.Exp inExp2;
  input DAE.Type inType2;
  input DAE.Operator inOp;
  input String suggestion;
protected
  String e1Str, t1Str, e2Str, t2Str, s1, s2, sugg;
algorithm
  e1Str := ExpressionDump.printExpStr(inExp1);
  t1Str := Types.unparseType(inType1);
  e2Str := ExpressionDump.printExpStr(inExp2);
  t2Str := Types.unparseType(inType2);
  s1 := "' " + e1Str + DAEDump.dumpOperatorSymbol(inOp) + e2Str + " '";
  s2 := "' " + t1Str + DAEDump.dumpOperatorString(inOp) + t2Str + " '";
  Error.addSourceMessage(Error.UNRESOLVABLE_TYPE, {s1,s2,suggestion}, Absyn.dummyInfo);
end binaryArrayOpError;

public function getCrefType
  input DAE.ComponentRef inCref;
  output DAE.Type outType;
protected
  DAE.Type baseTy;
  list<DAE.Dimension> dims, accdims;
algorithm
  (accdims,baseTy) := getCrefType2(inCref);
  if listLength(accdims) > 0 then
    outType := DAE.T_ARRAY(baseTy, accdims, DAE.emptyTypeSource);
  else
    outType := baseTy;
  end if;
end getCrefType;

function getCrefType2
  input DAE.ComponentRef inCref;
  input output list<DAE.Dimension> accDims = {};
  output DAE.Type baseType;
protected
  list<DAE.Dimension> dims;
algorithm
  _ := match inCref

    case DAE.CREF_IDENT()
      algorithm
        baseType := underlyingType(inCref.identType);
        dims := getTypeDims(inCref.identType);
        dims := applySubsToDims(dims, inCref.subscriptLst);
        accDims := dims;
      then ();

    case DAE.CREF_QUAL()
      algorithm
        (accDims,baseType) := getCrefType2(inCref.componentRef);
        dims := getTypeDims(inCref.identType);
        dims := applySubsToDims(dims, inCref.subscriptLst);
        accDims := listAppend(dims, accDims);
      then ();

    else
      fail();
  end match;
end getCrefType2;

public function getRangeType
  input DAE.Exp inStart;
  input DAE.Type inStartTy;
  input Option<DAE.Exp> inOptStep;
  input Option<DAE.Type> inOptStepTy;
  input DAE.Exp inEnd;
  input DAE.Type inEndTy;
  input SourceInfo info;
  output DAE.Type outType;
protected
  Boolean stepreal;
  DAE.Type stepty;
algorithm

  stepreal := false;
  if isNumeric(inStartTy) and isNumeric(inEndTy) then
    if isSome(inOptStepTy) then
	    SOME(stepty) := inOptStepTy;
	    if not isNumeric(stepty) then
	      Error.addInternalError("Invalid range expression. Step expression is not numeric type.", info);
	      fail();
	    end if;
	    stepreal := isReal(stepty);
    end if;
    try
      outType := getNumericRangeType(inStart, inOptStep, inEnd);
    else
      // TODO: for now let it be unknown. However the expression (end-start)/step + 1 should be the dim expression.
      if stepreal or isReal(inStartTy) or isReal(inEndTy) then
        outType := DAE.T_ARRAY(DAE.T_REAL_DEFAULT, {DAE.DIM_UNKNOWN()}, DAE.emptyTypeSource);
      else
        outType := DAE.T_ARRAY(DAE.T_INTEGER_DEFAULT, {DAE.DIM_UNKNOWN()}, DAE.emptyTypeSource);
      end if;
    end try;

  elseif isBoolean(inStartTy) and isBoolean(inEndTy) then
    if isSome(inOptStepTy) then
      Error.addInternalError("Invalid range expression. Non numeric range exressions can not have steps.", info);
      fail();
    end if;
    try
      outType := getBooleanRangeType(inStart, inOptStep, inEnd);
    else
      // TODO: for now let it be unknown. However an expression that can deduce the size from the possible true/false
      // combinations should be the dim expression.
      outType := DAE.T_ARRAY(DAE.T_BOOL_DEFAULT, {DAE.DIM_UNKNOWN()}, DAE.emptyTypeSource);
    end try;

  elseif isEnum(inStartTy) and isEnum(inEndTy) then
    if isSome(inOptStepTy) then
      Error.addInternalError("Invalid range expression. Non numeric range exressions can not have steps.", info);
      fail();
    end if;
    Error.addInternalError("Enumerator ranges are not handled yet.", info);
    fail();

  else
    Error.addInternalError("Invalid range expression. Start and end expressions have different types.", info);
    fail();
  end if;

end getRangeType;


function getNumericRangeType
  input DAE.Exp inStart;
  input Option<DAE.Exp> inOptStep;
  input DAE.Exp inEnd;
  output DAE.Type outType;
algorithm
  _ := match(inStart, inOptStep, inEnd)
    local
      Integer size;
      DAE.Exp step;
      DAE.Dimension dim;

    case (DAE.ICONST(),NONE(),DAE.ICONST())
      algorithm
        size := inEnd.integer - inStart.integer + 1;
        dim := DAE.DIM_INTEGER(size);
        outType := DAE.T_ARRAY(DAE.T_INTEGER_DEFAULT, {dim}, DAE.emptyTypeSource);
      then ();
    case (DAE.ICONST(),NONE(),DAE.RCONST())
      algorithm
        size := Util.realRangeSize(intReal(inStart.integer), 1.0, inEnd.real);
        dim := DAE.DIM_INTEGER(size);
        outType := DAE.T_ARRAY(DAE.T_REAL_DEFAULT, {dim}, DAE.emptyTypeSource);
      then ();
    case (DAE.RCONST(),NONE(),DAE.ICONST())
      algorithm
        size := Util.realRangeSize(inStart.real, 1.0, intReal(inEnd.integer));
        dim := DAE.DIM_INTEGER(size);
        outType := DAE.T_ARRAY(DAE.T_REAL_DEFAULT, {dim}, DAE.emptyTypeSource);
      then ();
    case (DAE.RCONST(),NONE(),DAE.RCONST())
      algorithm
        size := Util.realRangeSize(inStart.real, 1.0, inEnd.real);
        dim := DAE.DIM_INTEGER(size);
        outType := DAE.T_ARRAY(DAE.T_REAL_DEFAULT, {dim}, DAE.emptyTypeSource);
      then ();

    case (DAE.ICONST(),SOME(step as DAE.ICONST()),DAE.ICONST())
      algorithm
        size := inEnd.integer - inStart.integer;
        size := intDiv(size, step.integer) + 1;
        dim := DAE.DIM_INTEGER(size);
        outType := DAE.T_ARRAY(DAE.T_INTEGER_DEFAULT, {dim}, DAE.emptyTypeSource);
      then ();
    case (DAE.ICONST(),SOME(step as DAE.ICONST()),DAE.RCONST())
      algorithm
        size := Util.realRangeSize(intReal(inStart.integer), intReal(step.integer), inEnd.real);
        dim := DAE.DIM_INTEGER(size);
        outType := DAE.T_ARRAY(DAE.T_REAL_DEFAULT, {dim}, DAE.emptyTypeSource);
      then ();
    case (DAE.ICONST(),SOME(step as DAE.RCONST()),DAE.ICONST())
      algorithm
        size := Util.realRangeSize(intReal(inStart.integer), step.real, intReal(inEnd.integer));
        dim := DAE.DIM_INTEGER(size);
        outType := DAE.T_ARRAY(DAE.T_REAL_DEFAULT, {dim}, DAE.emptyTypeSource);
      then ();
    case (DAE.ICONST(),SOME(step as DAE.RCONST()),DAE.RCONST())
      algorithm
        size := Util.realRangeSize(intReal(inStart.integer), step.real, inEnd.real);
        dim := DAE.DIM_INTEGER(size);
        outType := DAE.T_ARRAY(DAE.T_REAL_DEFAULT, {dim}, DAE.emptyTypeSource);
      then ();

    case (DAE.RCONST(),SOME(step as DAE.ICONST()),DAE.ICONST())
      algorithm
        size := Util.realRangeSize(inStart.real, intReal(step.integer), intReal(inEnd.integer));
        dim := DAE.DIM_INTEGER(size);
        outType := DAE.T_ARRAY(DAE.T_REAL_DEFAULT, {dim}, DAE.emptyTypeSource);
      then ();
    case (DAE.RCONST(),SOME(step as DAE.ICONST()),DAE.RCONST())
      algorithm
        size := Util.realRangeSize(inStart.real, intReal(step.integer), inEnd.real);
        dim := DAE.DIM_INTEGER(size);
        outType := DAE.T_ARRAY(DAE.T_REAL_DEFAULT, {dim}, DAE.emptyTypeSource);
      then ();
    case (DAE.RCONST(),SOME(step as DAE.RCONST()),DAE.ICONST())
      algorithm
        size := Util.realRangeSize(inStart.real, step.real, intReal(inEnd.integer));
        dim := DAE.DIM_INTEGER(size);
        outType := DAE.T_ARRAY(DAE.T_REAL_DEFAULT, {dim}, DAE.emptyTypeSource);
      then ();
    case (DAE.RCONST(),SOME(step as DAE.RCONST()),DAE.RCONST())
      algorithm
        size := Util.realRangeSize(inStart.real, step.real, inEnd.real);
        dim := DAE.DIM_INTEGER(size);
        outType := DAE.T_ARRAY(DAE.T_REAL_DEFAULT, {dim}, DAE.emptyTypeSource);
      then ();
    else
      fail();
  end match;
end getNumericRangeType;

function getBooleanRangeType
  input DAE.Exp inStart;
  input Option<DAE.Exp> inOptStep;
  input DAE.Exp inEnd;
  output DAE.Type outType;
algorithm
  _ := match(inStart, inOptStep, inEnd)

    case (DAE.BCONST(true),NONE(),DAE.BCONST(false))
      algorithm
        outType := DAE.T_ARRAY(DAE.T_BOOL_DEFAULT, {DAE.DIM_INTEGER(0)}, DAE.emptyTypeSource);
      then ();
    case (DAE.BCONST(false),NONE(),DAE.BCONST(true))
      algorithm
        outType := DAE.T_ARRAY(DAE.T_BOOL_DEFAULT, {DAE.DIM_INTEGER(2)}, DAE.emptyTypeSource);
      then ();
    case (DAE.BCONST(),NONE(),DAE.BCONST())
      algorithm
        outType := DAE.T_ARRAY(DAE.T_BOOL_DEFAULT, {DAE.DIM_INTEGER(1)}, DAE.emptyTypeSource);
      then ();
    else
      fail();
  end match;
end getBooleanRangeType;

function checkIfExpression
  input DAE.Exp condExp;
  input DAE.Type condType;
  input DAE.Const condVar;
  input DAE.Exp thenExp;
  input DAE.Type thenType;
  input DAE.Const thenVar;
  input DAE.Exp elseExp;
  input DAE.Type elseType;
  input DAE.Const elseVar;
  input SourceInfo info;
  output DAE.Exp outExp;
  output DAE.Type outType;
  output DAE.Const outVar;
protected
   DAE.Exp ec, e1, e2;
   String s1, s2, s3, s4;
   Boolean tyMatch;
algorithm
  (ec, _, tyMatch) := Types.matchTypeNoFail(condExp, condType, DAE.T_BOOL_DEFAULT);

  // if the condtion is not boolean that's bad :)
  if not tyMatch then
    s1 := ExpressionDump.printExpStr(condExp);
    s2 := Types.unparseType(condType);
    Error.addSourceMessageAndFail(Error.IF_CONDITION_TYPE_ERROR , {s1, s2}, info);
  end if;

  (e1, e2, outType, tyMatch) :=
    Types.checkTypeCompat(thenExp, thenType, elseExp, elseType);

  // if the types are not matching, print an error and fail.
  if not tyMatch then
    s1 := ExpressionDump.printExpStr(thenExp);
    s2 := ExpressionDump.printExpStr(elseExp);
    s3 := Types.unparseTypeNoAttr(thenType);
    s4 := Types.unparseTypeNoAttr(elseType);
    Error.addSourceMessageAndFail(Error.TYPE_MISMATCH_IF_EXP,
      {"", s1, s3, s2, s4}, info);
  end if;

  outExp := DAE.IFEXP(ec, e1, e2);
  outType := thenType;
  outVar := Types.constAnd(thenVar, elseVar);
end checkIfExpression;

annotation(__OpenModelica_Interface="frontend");
end NFTypeCheck;
