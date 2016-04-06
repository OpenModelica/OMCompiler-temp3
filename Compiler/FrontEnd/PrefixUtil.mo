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

encapsulated package PrefixUtil
" file:         PrefixUtil.mo
  package:     PrefixUtil
  description: PrefixUtil management


  When instantiating an expression, there is a prefix that
  has to be added to each variable name to be able to use it in the
  flattened equation set.

  A prefix for a variable x could be for example a.b.c so that the
  fully qualified name is a.b.c.x."


public import Absyn;
public import DAE;
public import FCore;
public import FGraph;
public import Lookup;
public import SCode;
public import Prefix;
public import InnerOuter;
public import ClassInf;

protected type InstanceHierarchy = InnerOuter.InstHierarchy "an instance hierarchy";

protected import ComponentReference;
protected import Config;
protected import Debug;
protected import Expression;
protected import ExpressionDump;
protected import Flags;
protected import List;
protected import Print;
//protected import Util;
protected import System;
protected import Types;
protected import MetaModelica.Dangerous;

public function printPrefixStr "Prints a Prefix to a string."
  input Prefix.Prefix inPrefix;
  output String outString;
algorithm
  outString :=  matchcontinue (inPrefix)
    local
      String str,s,rest_1,s_1,s_2;
      Prefix.ComponentPrefix rest;
      Prefix.ClassPrefix cp;
      list<DAE.Subscript> ss;

    case Prefix.NOPRE() then "<Prefix.NOPRE()>";
    case Prefix.PREFIX(Prefix.NOCOMPPRE(),_) then "<Prefix.PREFIX(Prefix.NOCOMPPRE())>";
    case Prefix.PREFIX(Prefix.PRE(str,_,{},Prefix.NOCOMPPRE(),_,_),_) then str;
    case Prefix.PREFIX(Prefix.PRE(str,_,ss,Prefix.NOCOMPPRE(),_,_),_)
      equation
        s = stringAppend(str, "[" + stringDelimitList(
          List.map(ss, ExpressionDump.subscriptString), ", ") + "]");
      then
        s;
    case Prefix.PREFIX(Prefix.PRE(str,_,{},rest,_,_),cp)
      equation
        rest_1 = printPrefixStr(Prefix.PREFIX(rest,cp));
        s = stringAppend(rest_1, ".");
        s_1 = stringAppend(s, str);
      then
        s_1;
    case Prefix.PREFIX(Prefix.PRE(str,_,ss,rest,_,_),cp)
      equation
        rest_1 = printPrefixStr(Prefix.PREFIX(rest,cp));
        s = stringAppend(rest_1, ".");
        s_1 = stringAppend(s, str);
        s_2 = stringAppend(s_1, "[" + stringDelimitList(
          List.map(ss, ExpressionDump.subscriptString), ", ") + "]");
      then
        s_2;
  end matchcontinue;
end printPrefixStr;

public function printPrefixStr2 "Prints a Prefix to a string. Designed to be used in Error messages to produce qualified component names"
  input Prefix.Prefix inPrefix;
  output String outString;
algorithm
  outString :=  match (inPrefix)
  local
    Prefix.Prefix p;
  case Prefix.NOPRE() then "";
  case Prefix.PREFIX(Prefix.NOCOMPPRE(),_) then "";
  case p then printPrefixStr(p)+".";
  end match;
end printPrefixStr2;

public function printPrefixStr3 "Prints a Prefix to a string as a component name. Designed to be used in Error messages"
  input Prefix.Prefix inPrefix;
  output String outString;
algorithm
  outString :=  match (inPrefix)
  local
    Prefix.Prefix p;
  case Prefix.NOPRE() then "<NO COMPONENT>";
  case Prefix.PREFIX(Prefix.NOCOMPPRE(),_) then "<NO COMPONENT>";
  case p then printPrefixStr(p);
  end match;
end printPrefixStr3;

public function printPrefixStrIgnoreNoPre "Prints a Prefix to a string as a component name. Designed to be used in Error messages"
  input Prefix.Prefix inPrefix;
  output String outString;
algorithm
  outString :=  match (inPrefix)
  local
    Prefix.Prefix p;
  case Prefix.NOPRE() then "";
  case Prefix.PREFIX(Prefix.NOCOMPPRE(),_) then "";
  case p then printPrefixStr(p);
  end match;
end printPrefixStrIgnoreNoPre;

public function printPrefix "Prints a prefix to the Print buffer."
  input Prefix.Prefix p;
protected
  String s;
algorithm
  s := printPrefixStr(p);
  Print.printBuf(s);
end printPrefix;

public function prefixAdd "This function is used to extend a prefix with another level.  If
  the prefix `a.b{10}.c\' is extended with `d\' and an empty subscript
  list, the resulting prefix is `a.b{10}.c.d\'.  Remember that
  prefixes components are stored in the opposite order from the
  normal order used when displaying them."
  input String inIdent;
  input list<DAE.Dimension> inType;
  input list<DAE.Subscript> inIntegerLst;
  input Prefix.Prefix inPrefix;
  input SCode.Variability vt;
  input ClassInf.State ci_state;
  input SourceInfo inInfo;
  output Prefix.Prefix outPrefix;
algorithm
  outPrefix := match (inIdent,inType,inIntegerLst,inPrefix,vt,ci_state)
    local
      String i;
      list<DAE.Subscript> s;
      Prefix.ComponentPrefix p;

    case (i,_,s,Prefix.PREFIX(p,_),_,_)
      then Prefix.PREFIX(Prefix.PRE(i,inType,s,p,ci_state,inInfo),Prefix.CLASSPRE(vt));

    case(i,_,s,Prefix.NOPRE(),_,_)
      then Prefix.PREFIX(Prefix.PRE(i,inType,s,Prefix.NOCOMPPRE(),ci_state,inInfo),Prefix.CLASSPRE(vt));
  end match;
end prefixAdd;

public function prefixFirst
  input Prefix.Prefix inPrefix;
  output Prefix.Prefix outPrefix;
algorithm
  outPrefix := match (inPrefix)
    local
      String a;
      list<DAE.Subscript> b;
      Prefix.ClassPrefix cp;
      Prefix.ComponentPrefix c;
      ClassInf.State ci_state;
      list<DAE.Dimension> pdims;
      SourceInfo info;

    case (Prefix.PREFIX(Prefix.PRE(prefix = a, dimensions = pdims, subscripts = b,ci_state=ci_state, info = info),cp))
      then Prefix.PREFIX(Prefix.PRE(a,pdims,b,Prefix.NOCOMPPRE(),ci_state,info),cp);
  end match;
end prefixFirst;

public function prefixFirstCref
  "Returns the first cref in the prefix."
  input Prefix.Prefix inPrefix;
  output DAE.ComponentRef outCref;
protected
  String name;
  list<DAE.Subscript> subs;
algorithm
  Prefix.PREFIX(compPre = Prefix.PRE(prefix = name, subscripts = subs)) := inPrefix;
  outCref := DAE.CREF_IDENT(name, DAE.T_UNKNOWN_DEFAULT, subs);
end prefixFirstCref;

public function prefixLast "Returns the last NONPRE Prefix of a prefix"
  input Prefix.Prefix inPrefix;
  output Prefix.Prefix outPrefix;
algorithm
  outPrefix := matchcontinue (inPrefix)
    local
      Prefix.ComponentPrefix p;
      Prefix.Prefix res;
      Prefix.ClassPrefix cp;

    case ((res as Prefix.PREFIX(Prefix.PRE(next = Prefix.NOCOMPPRE()),_))) then res;

    case (Prefix.PREFIX(Prefix.PRE(next = p),cp))
      equation
        res = prefixLast(Prefix.PREFIX(p,cp));
      then
        res;
  end matchcontinue;
end prefixLast;

public function prefixStripLast
"@author: adrpo
 remove the last prefix from the component prefix"
  input Prefix.Prefix inPrefix;
  output Prefix.Prefix outPrefix;
algorithm
  outPrefix := match (inPrefix)
    local
      Prefix.ClassPrefix cp;
      Prefix.ComponentPrefix compPre;
    // we can't remove what it isn't there!
    case (Prefix.NOPRE()) then Prefix.NOPRE();
    // if there isn't any next prefix, return Prefix.NOPRE!
    case (Prefix.PREFIX(compPre,cp))
      equation
         compPre = compPreStripLast(compPre);
      then Prefix.PREFIX(compPre,cp);
  end match;
end prefixStripLast;

protected function compPreStripLast
"@author: adrpo
 remove the last prefix from the component prefix"
  input Prefix.ComponentPrefix inCompPrefix;
  output Prefix.ComponentPrefix outCompPrefix;
algorithm
  outCompPrefix := match(inCompPrefix)
    local
      Prefix.ComponentPrefix next;

    // nothing to remove!
    case Prefix.NOCOMPPRE() then Prefix.NOCOMPPRE();
    // we have something
    case Prefix.PRE(next = next) then next;
   end match;
end compPreStripLast;

public function prefixPath "Prefix a Path variable by adding the supplied
  prefix to it and returning a new Path."
  input Absyn.Path inPath;
  input Prefix.Prefix inPrefix;
  output Absyn.Path outPath;
algorithm
  outPath := match (inPath,inPrefix)
    local
      Absyn.Path p,p_1;
      String s;
      Prefix.ComponentPrefix ss;
      Prefix.ClassPrefix cp;

    case (p,Prefix.NOPRE()) then p;
    case (p,Prefix.PREFIX(Prefix.PRE(prefix = s,next = Prefix.NOCOMPPRE()),_))
      equation
        p_1 = Absyn.QUALIFIED(s,p);
      then p_1;
    case (p,Prefix.PREFIX(Prefix.PRE(prefix = s,next = ss),cp))
      equation
        p_1 = prefixPath(Absyn.QUALIFIED(s,p), Prefix.PREFIX(ss,cp));
      then p_1;
  end match;
end prefixPath;

public function prefixToPath "Convert a Prefix to a Path"
  input Prefix.Prefix inPrefix;
  output Absyn.Path outPath;
algorithm
  outPath := matchcontinue (inPrefix)
    local
      String s;
      Absyn.Path p;
      Prefix.ComponentPrefix ss;
      Prefix.ClassPrefix cp;

    case Prefix.NOPRE()
      equation
        /*Print.printBuf("#-- Error: Cannot convert empty prefix to a path\n");*/
      then
        fail();
    case Prefix.PREFIX(Prefix.PRE(prefix = s,next = Prefix.NOCOMPPRE()),_) then Absyn.IDENT(s);
    case Prefix.PREFIX(Prefix.PRE(prefix = s,next = ss),cp)
      equation
        p = prefixToPath(Prefix.PREFIX(ss,cp));
      then
        Absyn.QUALIFIED(s,p);
  end matchcontinue;
end prefixToPath;

public function prefixCref "Prefix a ComponentRef variable by adding the supplied prefix to
  it and returning a new ComponentRef.
  LS: Changed to call prefixToCref which is more general now"
  input FCore.Cache cache;
  input FCore.Graph env;
  input InnerOuter.InstHierarchy inIH;
  input Prefix.Prefix pre;
  input DAE.ComponentRef cref;
  output FCore.Cache outCache;
  output DAE.ComponentRef cref_1;
algorithm
  (outCache,cref_1) := match pre
    case Prefix.NOPRE()
      algorithm
        if System.getHasInnerOuterDefinitions() then
          (outCache,cref_1) := prefixToCref3(cache,env,inIH,Prefix.NOCOMPPRE(),cref);
        else
          outCache := cache;
          cref_1 := cref;
        end if;
      then (outCache,cref_1);
    case Prefix.PREFIX()
      algorithm
        (outCache,cref_1) := prefixToCref3(cache,env,inIH,pre.compPre,cref);
      then (outCache,cref_1);
  end match;
end prefixCref;

public function prefixCrefWork "Prefix a ComponentRef variable by adding the supplied prefix to
  it and returning a new ComponentRef.
  LS: Changed to call prefixToCref which is more general now"
  input FCore.Cache cache;
  input FCore.Graph env;
  input InnerOuter.InstHierarchy inIH;
  input Prefix.ComponentPrefix pre;
  input DAE.ComponentRef cref;
  output FCore.Cache outCache;
  output DAE.ComponentRef cref_1;
algorithm
  (outCache,cref_1) := prefixToCref3(cache,env,inIH,pre,cref);
end prefixCrefWork;

public function prefixCrefNoContext "Prefix a ComponentRef variable by adding the supplied prefix to
  it and returning a new ComponentRef.
  LS: Changed to call prefixToCref which is more general now"
  input Prefix.Prefix inPre;
  input DAE.ComponentRef inCref;
  output DAE.ComponentRef outCref;
algorithm
  outCref := match inPre
    case Prefix.NOPRE() then inCref;
    case Prefix.PREFIX()
      algorithm
        (_, outCref) := prefixToCref3(FCore.noCache(), FGraph.empty(), InnerOuter.emptyInstHierarchy, inPre.compPre, inCref);
      then outCref;
  end match;
end prefixCrefNoContext;

public function prefixToCref "Convert a prefix to a component reference."
  input Prefix.Prefix pre;
  output DAE.ComponentRef cref_1;
algorithm
  cref_1 := match pre
    case Prefix.PREFIX()
      algorithm
        (_,cref_1) := prefixToCref2(FCore.noCache(), FGraph.empty(), InnerOuter.emptyInstHierarchy, pre.compPre);
      then cref_1;
  end match;
end prefixToCref;

protected function prefixToCref2 "Convert a prefix to a component reference. Converting Prefix.NOPRE with no
  component reference is an error because a component reference cannot be
  empty"
  input FCore.Cache inCache;
  input FCore.Graph inEnv;
  input InstanceHierarchy inIH;
  input Prefix.ComponentPrefix inPrefix;
  output FCore.Cache outCache;
  output DAE.ComponentRef outComponentRef;
algorithm
  (outCache,outComponentRef) := match (inCache,inEnv,inIH,inPrefix)
    local
      DAE.ComponentRef cref,cref_1,cref_2,cref_;
      String i;
      list<DAE.Subscript> s;
      list<DAE.Dimension> ds;
      DAE.Type ident_ty;
      Prefix.ComponentPrefix xs;
      Prefix.ClassPrefix cp;
      ClassInf.State ci_state;
      FCore.Cache cache;
      FCore.Graph env;
    case (cache,env,_,Prefix.PRE(prefix = i,dimensions=ds,subscripts = s,next = xs,ci_state=ci_state))
      equation
        ident_ty = Expression.liftArrayLeftList(DAE.T_COMPLEX(ci_state, {}, NONE(), DAE.emptyTypeSource), ds);
        cref_ = ComponentReference.makeCrefIdent(i,ident_ty,s);
        (cache,cref_1) = prefixToCref3(cache,env,inIH,xs,cref_);
      then (cache,cref_1);
  end match;
end prefixToCref2;

protected function prefixToCref3 "Convert a prefix to a component reference. Converting Prefix.NOPRE with no
  component reference is an error because a component reference cannot be
  empty"
  input FCore.Cache inCache;
  input FCore.Graph inEnv;
  input InstanceHierarchy inIH;
  input Prefix.ComponentPrefix inPrefix;
  input DAE.ComponentRef inCref;
  output FCore.Cache outCache;
  output DAE.ComponentRef outComponentRef;
algorithm
  (outCache,outComponentRef) := match (inCache,inEnv,inIH,inPrefix,inCref)
    local
      DAE.ComponentRef cref,cref_1,cref_2,cref_;
      String i;
      list<DAE.Subscript> s;
      list<DAE.Dimension> ds;
      DAE.Type ident_ty;
      Prefix.ComponentPrefix xs;
      Prefix.ClassPrefix cp;
      ClassInf.State ci_state;
      FCore.Cache cache;
      FCore.Graph env;

    case (cache,_,_,Prefix.NOCOMPPRE(),cref) then (cache,cref);
    case (cache,env,_,Prefix.PRE(prefix = i,dimensions=ds,subscripts = s,next = xs,ci_state=ci_state),cref)
      equation
        (cache,cref) = prefixSubscriptsInCref(cache,env,inIH,inPrefix,cref);
        ident_ty = Expression.liftArrayLeftList(DAE.T_COMPLEX(ci_state, {}, NONE(), DAE.emptyTypeSource), ds);
        cref_2 = ComponentReference.makeCrefQual(i,ident_ty,s,cref);
        (cache,cref_1) = prefixToCref3(cache,env,inIH,xs,cref_2);
      then
        (cache,cref_1);
  end match;
end prefixToCref3;

public function prefixToCrefOpt "Convert a prefix to an optional component reference."
  input Prefix.Prefix pre;
  output Option<DAE.ComponentRef> cref_1;
algorithm
  cref_1 := prefixToCrefOpt2(pre, NONE());
end prefixToCrefOpt;

public function prefixToCrefOpt2 "Convert a prefix to a component reference. Converting Prefix.NOPRE with no
  component reference gives a NONE"
  input Prefix.Prefix inPrefix;
  input Option<DAE.ComponentRef> inExpComponentRefOption;
  output Option<DAE.ComponentRef> outComponentRefOpt;
algorithm
  outComponentRefOpt := match (inPrefix,inExpComponentRefOption)
    local
      Option<DAE.ComponentRef> cref_1;
      DAE.ComponentRef cref,cref_;
      String i;
      list<DAE.Subscript> s;
      Prefix.ComponentPrefix xs;
      Prefix.ClassPrefix cp;

    case (Prefix.NOPRE(),NONE()) then NONE();
    case (Prefix.NOPRE(),SOME(cref)) then SOME(cref);
    case (Prefix.PREFIX(Prefix.NOCOMPPRE(),_),SOME(cref)) then SOME(cref);
    case (Prefix.PREFIX(Prefix.PRE(prefix = i,subscripts = s,next = xs),cp),NONE())
      equation
        cref_ = ComponentReference.makeCrefIdent(i,DAE.T_COMPLEX(ClassInf.UNKNOWN(Absyn.IDENT("")), {}, NONE(), DAE.emptyTypeSource),s);
        cref_1 = prefixToCrefOpt2(Prefix.PREFIX(xs,cp), SOME(cref_));
      then
        cref_1;
    case (Prefix.PREFIX(Prefix.PRE(prefix = i,subscripts = s,next = xs),cp),SOME(cref))
      equation
        cref_ = ComponentReference.makeCrefQual(i,DAE.T_COMPLEX(ClassInf.UNKNOWN(Absyn.IDENT("")), {}, NONE(), DAE.emptyTypeSource),s,cref);
        cref_1 = prefixToCrefOpt2(Prefix.PREFIX(xs,cp), SOME(cref_));
      then
        cref_1;
  end match;
end prefixToCrefOpt2;

public function makeCrefFromPrefixNoFail
"@author:adrpo
   Similar to prefixToCref but it doesn't fail for NOPRE or NOCOMPPRE,
   it will just create an empty cref in these cases"
  input Prefix.Prefix pre;
  output DAE.ComponentRef cref;
algorithm
  cref := matchcontinue(pre)
    local
      DAE.ComponentRef c;

    case(Prefix.NOPRE())
      equation
        c = ComponentReference.makeCrefIdent("", DAE.T_UNKNOWN_DEFAULT, {});
      then
        c;

    case(Prefix.PREFIX(Prefix.NOCOMPPRE(), _))
      equation
        c = ComponentReference.makeCrefIdent("", DAE.T_UNKNOWN_DEFAULT, {});
      then
        c;

    case _
      equation
        c = prefixToCref(pre);
      then
        c;
  end matchcontinue;
end makeCrefFromPrefixNoFail;

protected function prefixSubscriptsInCref "help function to prefixToCrefOpt2, deals with prefixing expressions in subscripts"
  input FCore.Cache inCache;
  input FCore.Graph inEnv;
  input InstanceHierarchy inIH;
  input Prefix.ComponentPrefix pre;
  input DAE.ComponentRef inCr;
  output FCore.Cache outCache;
  output DAE.ComponentRef outCr;
algorithm
  (outCache,outCr) := prefixSubscriptsInCrefWork(inCache,inEnv,inIH,pre,inCr,{});
end prefixSubscriptsInCref;

protected function prefixSubscriptsInCrefWork "help function to prefixToCrefOpt2, deals with prefixing expressions in subscripts"
  input FCore.Cache inCache;
  input FCore.Graph inEnv;
  input InstanceHierarchy inIH;
  input Prefix.ComponentPrefix pre;
  input DAE.ComponentRef inCr;
  input list<DAE.ComponentRef> acc;
  output FCore.Cache outCache;
  output DAE.ComponentRef outCr;
algorithm
  (outCache,outCr) := match (inCache,inEnv,inIH,pre,inCr,acc)
    local
      DAE.Ident id;
      DAE.Type tp;
      list<DAE.Subscript> subs;
      FCore.Cache cache;
      FCore.Graph env;
      DAE.ComponentRef cr,crid;
    case(cache,env,_,_,DAE.CREF_IDENT(id,tp,subs),_)
      equation
        (cache,subs) = prefixSubscripts(cache,env,inIH,pre,subs);
        cr = ComponentReference.makeCrefIdent(id,tp,subs);
      then (cache,ComponentReference.implode_reverse(cr::acc));
    case(cache,env,_,_,DAE.CREF_QUAL(id,tp,subs,cr),_)
      equation
        (cache,subs) = prefixSubscripts(cache,env,inIH,pre,subs);
        crid = ComponentReference.makeCrefIdent(id,tp,subs);
        (cache,cr) = prefixSubscriptsInCrefWork(cache,env,inIH,pre,cr,crid::acc);
      then (cache,cr);
    case(cache,_,_,_,DAE.WILD(),_) then (cache,DAE.WILD());
  end match;
end prefixSubscriptsInCrefWork;

protected function prefixSubscripts "help function to prefixSubscriptsInCref, adds prefix to subscripts"
  input FCore.Cache inCache;
  input FCore.Graph inEnv;
  input InstanceHierarchy inIH;
  input Prefix.ComponentPrefix pre;
  input list<DAE.Subscript> inSubs;
  output FCore.Cache outCache;
  output list<DAE.Subscript> outSubs;
algorithm
  (outCache,outSubs) := match(inCache,inEnv,inIH,pre,inSubs)
    local
      DAE.Subscript sub;
      FCore.Cache cache;
      FCore.Graph env;
      list<DAE.Subscript> subs;

    case (cache,_,_,_,{}) then (cache,{});

    case (cache,env,_,_,sub::subs)
      equation
        (cache,sub) = prefixSubscript(cache,env,inIH,pre,sub);
        (cache,subs) = prefixSubscripts(cache,env,inIH,pre,subs);
      then (cache,sub::subs);
  end match;
end prefixSubscripts;

protected function prefixSubscript "help function to prefixSubscripts, adds prefix to one subscript, if it is an expression"
  input FCore.Cache inCache;
  input FCore.Graph inEnv;
  input InstanceHierarchy inIH;
  input Prefix.ComponentPrefix pre;
  input DAE.Subscript sub;
  output FCore.Cache outCache;
  output DAE.Subscript outSub;
algorithm
  (outCache,outSub) := match(inCache,inEnv,inIH,pre,sub)
    local
      DAE.Exp exp;
      FCore.Cache cache;
      FCore.Graph env;

    case(cache,_,_,_,DAE.WHOLEDIM()) then (cache,DAE.WHOLEDIM());

    case(cache,env,_,_,DAE.SLICE(exp)) equation
      (cache,exp) = prefixExpWork(cache,env,inIH,exp,pre);
    then (cache,DAE.SLICE(exp));

    case(cache,env,_,_,DAE.WHOLE_NONEXP(exp)) equation
      (cache,exp) = prefixExpWork(cache,env,inIH,exp,pre);
    then (cache,DAE.WHOLE_NONEXP(exp));

    case(cache,env,_,_,DAE.INDEX(exp)) equation
      (cache,exp) = prefixExpWork(cache,env,inIH,exp,pre);
    then (cache,DAE.INDEX(exp));

  end match;
end prefixSubscript;

protected function prefixCrefInnerOuter "Search for the prefix of the inner when the cref is
  an outer and add that instead of the given prefix!
  If the cref is an inner, prefix it normally."
  input FCore.Cache inCache;
  input FCore.Graph inEnv;
  input InnerOuter.InstHierarchy inIH;
  input DAE.ComponentRef inCref;
  input Prefix.ComponentPrefix inPrefix;
  output FCore.Cache outCache;
  output DAE.ComponentRef outCref;
algorithm
  (outCache,outCref) := match (inCache,inEnv,inIH,inCref,inPrefix)
    local
      FCore.Cache cache;
      FCore.Graph env;
      Absyn.InnerOuter io;
      InstanceHierarchy ih;
      Prefix.ComponentPrefix innerPrefix, pre;
      DAE.ComponentRef lastCref, cref, newCref;
      String n;


    case (cache,_,ih,cref,pre)
      equation
        newCref = InnerOuter.prefixOuterCrefWithTheInnerPrefix(ih, cref, pre);
      then
        (cache,newCref);

  end match;
end prefixCrefInnerOuter;

public function prefixExp "Add the supplied prefix to all component references in an expression."
  input FCore.Cache inCache;
  input FCore.Graph inEnv;
  input InnerOuter.InstHierarchy inIH;
  input DAE.Exp inExp;
  input Prefix.Prefix inPrefix;
  output FCore.Cache outCache;
  output DAE.Exp outExp;
algorithm
  (outCache,outExp) := match inPrefix
    case Prefix.NOPRE()
      algorithm
        if System.getHasInnerOuterDefinitions() then
          (outCache,outExp) := prefixExpWork(inCache,inEnv,inIH,inExp,Prefix.NOCOMPPRE());
        else
          outCache := inCache;
          outExp := inExp;
        end if;
      then (outCache,outExp);
    case Prefix.PREFIX()
      algorithm
        (outCache,outExp) := prefixExpWork(inCache,inEnv,inIH,inExp,inPrefix.compPre);
      then (outCache,outExp);
  end match;
end prefixExp;

protected function prefixExpWork "Add the supplied prefix to all component references in an expression."
  input FCore.Cache inCache;
  input FCore.Graph inEnv;
  input InnerOuter.InstHierarchy inIH;
  input DAE.Exp inExp;
  input Prefix.ComponentPrefix pre;
  output FCore.Cache outCache;
  output DAE.Exp outExp;
algorithm
  (outCache,outExp) := match (inCache,inEnv,inIH,inExp,pre)
    local
      DAE.Exp e,e1_1,e2_1,e1,e2,e3_1,e3,cref_1,dim_1,cref,dim,start_1,stop_1,start,stop,step_1,step,e_1,exp_1,exp,crefExp;
      DAE.ComponentRef cr,cr_1;
      FCore.Graph env;
      DAE.Operator o;
      list<DAE.Exp> es_1,es;
      Absyn.Path f;
      Boolean sc;
      list<DAE.Exp> x_1,x;
      list<list<DAE.Exp>> xs_1,xs;
      String s;
      FCore.Cache cache;
      list<DAE.Exp> expl;
      InstanceHierarchy ih;
      Prefix.Prefix p;
      Integer b,a;
      DAE.Type t,tp;
      Integer index_;
      Option<tuple<DAE.Exp,Integer,Integer>> isExpisASUB;
      DAE.ReductionInfo reductionInfo;
      DAE.ReductionIterators riters;
      DAE.CallAttributes attr;
      list<String> fieldNames;
      DAE.ClockKind clk;

    // adrpo: handle prefixing of inner/outer variables
    case (cache,env,ih,DAE.CREF(componentRef = cr,ty = t),_)
      algorithm
        if System.getHasInnerOuterDefinitions() then
          try
            cr_1 := InnerOuter.prefixOuterCrefWithTheInnerPrefix(ih, cr, pre);
            (outCache, t) := prefixExpressionsInTypeWork(cache, env, ih, pre, t);
            outExp := Expression.makeCrefExp(cr_1, t);
            return;
          else
          end try;
        end if;
        outExp := match pre
          case Prefix.NOCOMPPRE() then inExp;
          else
            algorithm
              (cache,outExp) := prefixExpCref(cache, env, ih, inExp, pre);
            then outExp;
        end match;
      then
        (cache,outExp);

    // no prefix, return the input expression
    case (cache,_,_,e,Prefix.NOCOMPPRE())
      then (cache,e);

    // handle literal constants
    case (cache,_,_,(e as DAE.ICONST()),_) then (cache,e);
    case (cache,_,_,(e as DAE.RCONST()),_) then (cache,e);
    case (cache,_,_,(e as DAE.SCONST()),_) then (cache,e);
    case (cache,_,_,(e as DAE.BCONST()),_) then (cache,e);
    case (cache,_,_,(e as DAE.ENUM_LITERAL()), _) then (cache, e);

    // clocks
    case (cache, env, ih, DAE.CLKCONST(clk), _)
      equation
        (cache, clk) = prefixClockKind(cache, env, ih, clk, pre);
      then
        (cache, DAE.CLKCONST(clk));

    case (cache,env,ih,(DAE.ASUB(exp = e1, sub = expl)),_)
      equation
        (cache, es_1) = prefixExpListWork(cache, env, ih, expl, pre);
        (cache, e1) = prefixExpWork(cache, env, ih, e1, pre);
        e2 = Expression.makeASUB(e1,es_1);
      then
        (cache, e2);

    case (cache,env,ih,(DAE.TSUB(e1, index_, t)),_)
      equation
        (cache,e1) = prefixExpWork(cache, env, ih, e1, pre);
        e2 = DAE.TSUB(e1, index_, t);
      then
        (cache,e2);

    case (cache,env,ih,DAE.BINARY(exp1 = e1,operator = o,exp2 = e2),_)
      equation
        (cache,e1_1) = prefixExpWork(cache, env, ih, e1, pre);
        (cache,e2_1) = prefixExpWork(cache, env, ih, e2, pre);
      then
        (cache,DAE.BINARY(e1_1,o,e2_1));

    case (cache,env,ih,DAE.UNARY(operator = o,exp = e1),_)
      equation
        (cache,e1_1) = prefixExpWork(cache, env, ih, e1, pre);
      then
        (cache,DAE.UNARY(o,e1_1));

    case (cache,env,ih,DAE.LBINARY(exp1 = e1,operator = o,exp2 = e2),_)
      equation
        (cache,e1_1) = prefixExpWork(cache, env, ih, e1, pre);
        (cache,e2_1) = prefixExpWork(cache, env, ih, e2, pre);
      then
        (cache,DAE.LBINARY(e1_1,o,e2_1));

    case (cache,env,ih,DAE.LUNARY(operator = o,exp = e1),_)
      equation
        (cache,e1_1) = prefixExpWork(cache, env, ih, e1, pre);
      then
        (cache,DAE.LUNARY(o,e1_1));

    case (cache,env,ih,DAE.RELATION(exp1 = e1,operator = o,exp2 = e2, index=index_, optionExpisASUB= isExpisASUB),_)
      equation
        (cache,e1_1) = prefixExpWork(cache, env, ih, e1, pre);
        (cache,e2_1) = prefixExpWork(cache, env, ih, e2, pre);
      then
        (cache,DAE.RELATION(e1_1,o,e2_1,index_,isExpisASUB));

    case (cache,env,ih,DAE.IFEXP(expCond = e1,expThen = e2,expElse = e3),_)
      equation
        (cache,e1_1) = prefixExpWork(cache, env, ih, e1, pre);
        (cache,e2_1) = prefixExpWork(cache, env, ih, e2, pre);
        (cache,e3_1) = prefixExpWork(cache, env, ih, e3, pre);
      then
        (cache,DAE.IFEXP(e1_1,e2_1,e3_1));

    case (cache,env,ih,DAE.SIZE(exp = cref,sz = SOME(dim)),_)
      equation
        (cache,cref_1) = prefixExpWork(cache, env, ih, cref, pre);
        (cache,dim_1) = prefixExpWork(cache, env, ih, dim, pre);
      then
        (cache,DAE.SIZE(cref_1,SOME(dim_1)));

    case (cache,env,ih,DAE.SIZE(exp = cref,sz = NONE()),_)
      equation
        (cache,cref_1) = prefixExpWork(cache, env, ih, cref, pre);
      then
        (cache,DAE.SIZE(cref_1,NONE()));

    case (cache,env,ih,DAE.CALL(f,es,attr),_)
      equation
        (cache,es_1) = prefixExpListWork(cache, env, ih, es, pre);
      then
        (cache,DAE.CALL(f,es_1,attr));

    case (cache,env,ih,DAE.RECORD(f,es,fieldNames,t),_)
      equation
        (cache,_) = prefixExpListWork(cache, env, ih, es, pre);
      then
        (cache,DAE.RECORD(f,es,fieldNames,t));

    case (cache,_,_,DAE.ARRAY(ty = t,scalar = sc,array = {}),_)
      then
        (cache,DAE.ARRAY(t,sc,{}));

    case (cache,env,ih,DAE.ARRAY(ty = t,scalar = sc,array = es),_)
      equation
        (cache,es_1) = prefixExpListWork(cache, env, ih, es, pre);
      then
        (cache,DAE.ARRAY(t,sc,es_1));

    case (cache,env,ih,DAE.TUPLE(PR = es),_)
      equation
        (cache,es_1) = prefixExpListWork(cache, env, ih, es, pre);
      then
        (cache,DAE.TUPLE(es_1));

    case (cache,_,_,DAE.MATRIX(ty = t,integer = a,matrix = {}),_)
      then
        (cache,DAE.MATRIX(t,a,{}));

    case (cache,env,ih,DAE.MATRIX(ty = t,integer = a,matrix = (x :: xs)),_)
      equation
        (cache,x_1) = prefixExpListWork(cache, env, ih, x, pre);
        (cache,DAE.MATRIX(t,_,xs_1)) = prefixExpWork(cache, env, ih, DAE.MATRIX(t,a,xs), pre);
      then
        (cache,DAE.MATRIX(t,a,(x_1 :: xs_1)));

    case (cache,env,ih,DAE.RANGE(ty = t,start = start,step = NONE(),stop = stop),_)
      equation
        (cache,start_1) = prefixExpWork(cache, env, ih, start, pre);
        (cache,stop_1) = prefixExpWork(cache, env, ih, stop, pre);
      then
        (cache,DAE.RANGE(t,start_1,NONE(),stop_1));

    case (cache,env,ih,DAE.RANGE(ty = t,start = start,step = SOME(step),stop = stop),_)
      equation
        (cache,start_1) = prefixExpWork(cache, env, ih, start, pre);
        (cache,step_1) = prefixExpWork(cache, env, ih, step, pre);
        (cache,stop_1) = prefixExpWork(cache, env, ih, stop, pre);
      then
        (cache,DAE.RANGE(t,start_1,SOME(step_1),stop_1));

    case (cache,env,ih,DAE.CAST(ty = tp,exp = e),_)
      equation
        (cache,e_1) = prefixExpWork(cache, env, ih, e, pre);
      then
        (cache,DAE.CAST(tp,e_1));

    case (cache,env,ih,DAE.REDUCTION(reductionInfo = reductionInfo,expr = exp,iterators = riters),_)
      equation
        (cache,exp_1) = prefixExpWork(cache, env, ih, exp, pre);
        (cache,riters) = prefixIterators(cache, env, ih, riters, pre);
      then
        (cache,DAE.REDUCTION(reductionInfo,exp_1,riters));

    // MetaModelica extension. KS
    case (cache,env,ih,DAE.LIST(es),_)
      equation
        (cache,es_1) = prefixExpListWork(cache, env, ih, es, pre);
      then (cache,DAE.LIST(es_1));

    case (cache,env,ih,DAE.CONS(e1,e2),_)
      equation
        (cache,e1) = prefixExpWork(cache, env, ih, e1, pre);
        (cache,e2) = prefixExpWork(cache, env, ih, e2, pre);
      then (cache,DAE.CONS(e1,e2));

    case (cache,env,ih,DAE.META_TUPLE(es),_)
      equation
        (cache,es_1) = prefixExpListWork(cache, env, ih, es, pre);
      then (cache,DAE.META_TUPLE(es_1));

    case (cache,env,ih,DAE.META_OPTION(SOME(e1)),_)
      equation
        (cache,e1) = prefixExpWork(cache, env, ih, e1, pre);
      then (cache,DAE.META_OPTION(SOME(e1)));

    case (cache,_,_,DAE.META_OPTION(NONE()),_)
      equation
      then (cache,DAE.META_OPTION(NONE()));
        // ------------------------

    case (_,_,_,e,_)
      equation
        true = Flags.isSet(Flags.FAILTRACE);
        Debug.trace("-PrefixUtil.prefixExp failed on exp: ");
        s = ExpressionDump.printExpStr(e);
        Debug.traceln(s);
      then
        fail();
  end match;
end prefixExpWork;

protected function prefixExpCref
  "Helper function to prefixExp for prefixing a cref expression."
  input FCore.Cache inCache;
  input FCore.Graph inEnv;
  input InstanceHierarchy inIH;
  input DAE.Exp inCref;
  input Prefix.ComponentPrefix inPrefix;
  output FCore.Cache outCache;
  output DAE.Exp outCref;
protected
  Option<Boolean> is_iter;
  FCore.Cache cache;
  DAE.ComponentRef cr;
algorithm
  DAE.CREF(componentRef = cr) := inCref;
  (is_iter, cache) := Lookup.isIterator(inCache, inEnv, cr);
  (outCache, outCref) := prefixExpCref2(cache, inEnv, inIH, is_iter, inCref, inPrefix);
end prefixExpCref;

protected function prefixExpCref2
  input FCore.Cache inCache;
  input FCore.Graph inEnv;
  input InstanceHierarchy inIH;
  input Option<Boolean> inIsIter;
  input DAE.Exp inCref;
  input Prefix.ComponentPrefix inPrefix;
  output FCore.Cache outCache;
  output DAE.Exp outCref;
algorithm
  (outCache, outCref) := match(inCache, inEnv, inIH, inIsIter, inCref, inPrefix)
    local
      FCore.Cache cache;
      DAE.ComponentRef cr;
      DAE.Type ty;
      DAE.Exp exp;

    // A cref found in the current scope that's not an iterator.
    case (cache, _, _, SOME(false), DAE.CREF(componentRef = cr, ty = ty), _)
      equation
        (cache, cr) = prefixCrefWork(cache, inEnv, inIH, inPrefix, cr);
        (cache, ty) = prefixExpressionsInTypeWork(cache, inEnv, inIH, inPrefix, ty);
        exp = Expression.makeCrefExp(cr, ty);
      then
        (cache, exp);

    // An iterator, shouldn't be prefixed.
    case (_, _, _, SOME(true), _, _)
      then (inCache, inCref);

    // A cref not found in the current scope.
    case (cache, _, _, NONE(), DAE.CREF(componentRef = cr, ty = ty), _)
      equation
        (cache, cr) = prefixSubscriptsInCref(cache, inEnv, inIH, inPrefix, cr);
        (cache, ty) = prefixExpressionsInTypeWork(cache, inEnv, inIH, inPrefix, ty);
        exp = Expression.makeCrefExp(cr, ty);
      then
        (cache, exp);

  end match;
end prefixExpCref2;

protected function prefixIterators
  input FCore.Cache inCache;
  input FCore.Graph inEnv;
  input InstanceHierarchy ih;
  input DAE.ReductionIterators inIters;
  input Prefix.ComponentPrefix pre;
  output FCore.Cache outCache;
  output DAE.ReductionIterators outIters;
algorithm
  (outCache,outIters) := match (inCache,inEnv,ih,inIters,pre)
    local
      String id;
      DAE.Exp exp,gexp;
      DAE.Type ty;
      DAE.ReductionIterator iter;
      FCore.Cache cache;
      FCore.Graph env;
      DAE.ReductionIterators iters;

    case (cache,_,_,{},_) then (cache,{});
    case (cache,env,_,DAE.REDUCTIONITER(id,exp,SOME(gexp),ty)::iters,_)
      equation
        (cache,exp) = prefixExpWork(cache,env,ih,exp,pre);
        (cache,gexp) = prefixExpWork(cache,env,ih,gexp,pre);
        iter = DAE.REDUCTIONITER(id,exp,SOME(gexp),ty);
        (cache,iters) = prefixIterators(cache,env,ih,iters,pre);
      then (cache,iter::iters);
    case (cache,env,_,DAE.REDUCTIONITER(id,exp,NONE(),ty)::iters,_)
      equation
        (cache,exp) = prefixExpWork(cache,env,ih,exp,pre);
        iter = DAE.REDUCTIONITER(id,exp,NONE(),ty);
        (cache,iters) = prefixIterators(cache,env,ih,iters,pre);
      then (cache,iter::iters);
  end match;
end prefixIterators;

public function prefixExpList "This function prefixes a list of expressions using the prefixExp function."
  input FCore.Cache inCache;
  input FCore.Graph inEnv;
  input InnerOuter.InstHierarchy inIH;
  input list<DAE.Exp> inExpExpLst;
  input Prefix.Prefix inPrefix;
  output FCore.Cache outCache;
  output list<DAE.Exp> outExpExpLst;
algorithm
  (outCache,outExpExpLst) := match inPrefix
    case Prefix.NOPRE()
      algorithm
        if System.getHasInnerOuterDefinitions() then
          (outCache,outExpExpLst) := prefixExpListWork(inCache,inEnv,inIH,inExpExpLst,Prefix.NOCOMPPRE());
        else
          outCache := inCache;
          outExpExpLst := inExpExpLst;
        end if;
      then (outCache,outExpExpLst);
    case Prefix.PREFIX()
      algorithm
        (outCache,outExpExpLst) := prefixExpListWork(inCache,inEnv,inIH,inExpExpLst,inPrefix.compPre);
      then (outCache,outExpExpLst);
  end match;
end prefixExpList;

protected function prefixExpListWork "This function prefixes a list of expressions using the prefixExp function."
  input FCore.Cache inCache;
  input FCore.Graph inEnv;
  input InnerOuter.InstHierarchy inIH;
  input list<DAE.Exp> inExpExpLst;
  input Prefix.ComponentPrefix inPrefix;
  output FCore.Cache outCache;
  output list<DAE.Exp> outExpExpLst;
algorithm
  (outCache,outExpExpLst) := match (inCache,inEnv,inIH,inExpExpLst,inPrefix)
    local
      DAE.Exp e_1,e;
      list<DAE.Exp> es_1,es;
      FCore.Graph env;
      FCore.Cache cache;
      InstanceHierarchy ih;

    // handle empty case
    case (cache,_,_,{},_) then (cache,{});

    // yuppie! we have a list of expressions
    case (cache,env,ih,(e :: es),_)
      equation
        (cache,e_1) = prefixExpWork(cache, env, ih, e, inPrefix);
        (cache,es_1) = prefixExpListWork(cache, env, ih, es, inPrefix);
      then
        (cache,e_1 :: es_1);
  end match;
end prefixExpListWork;

//--------------------------------------------
//   PART OF THE WORKAROUND FOR VALUEBLOCKS. KS
protected function prefixStatements "Prefix statements.
  PART OF THE WORKAROUND FOR VALUEBLOCKS"
  input FCore.Cache cache;
  input FCore.Graph env;
  input InstanceHierarchy inIH;
  input list<DAE.Statement> stmts;
  input Prefix.ComponentPrefix p;
  output FCore.Cache outCache = cache;
  output list<DAE.Statement> outStmts = {};
protected
algorithm
  for st in stmts loop
    _ := match st
      local
        DAE.Type t;
        DAE.Exp e,e1,e2,e3;
        DAE.ElementSource source;
        DAE.Statement elem;

      list<DAE.Statement> localAccList,rest;
      Prefix.Prefix pre;
      InstanceHierarchy ih;
      list<DAE.Statement> elems,sList,b;
      String s,id;
      list<DAE.Exp> eLst;
      DAE.ComponentRef cRef;
      Boolean bool;
      DAE.Else elseBranch;
      Integer ix;
      case DAE.STMT_ASSIGN(t,e1,e,source)
        equation
          (outCache,e1) = prefixExpWork(outCache,env,inIH,e1,p);
          (outCache,e) = prefixExpWork(outCache,env,inIH,e,p);
          elem = DAE.STMT_ASSIGN(t,e1,e,source);
          outStmts = elem::outStmts;
        then ();

      case DAE.STMT_TUPLE_ASSIGN(t,eLst,e,source)
        equation
          (outCache,e) = prefixExpWork(outCache,env,inIH,e,p);
          (outCache,eLst) = prefixExpListWork(outCache,env,inIH,eLst,p);
          elem = DAE.STMT_TUPLE_ASSIGN(t,eLst,e,source);
          outStmts = elem::outStmts;
        then ();

      case DAE.STMT_ASSIGN_ARR(t,e1,e,source)
        equation
          (outCache,e1) = prefixExpWork(outCache,env,inIH,e1,p);
          (outCache,e) = prefixExpWork(outCache,env,inIH,e,p);
          elem = DAE.STMT_ASSIGN_ARR(t,e1,e,source);
          outStmts = elem::outStmts;
        then ();

      case DAE.STMT_FOR(t,bool,id,ix,e,sList,source)
        equation
          (outCache,e) = prefixExpWork(outCache,env,inIH,e,p);
          (outCache,sList) = prefixStatements(outCache,env,inIH,sList,p);
          elem = DAE.STMT_FOR(t,bool,id,ix,e,sList,source);
          outStmts = elem::outStmts;
        then ();

      case DAE.STMT_IF(e1,sList,elseBranch,source)
        equation
          (outCache,e1) = prefixExpWork(outCache,env,inIH,e1,p);
          (outCache,sList) = prefixStatements(outCache,env,inIH,sList,p);
          (outCache,elseBranch) = prefixElse(outCache,env,inIH,elseBranch,p);
          elem = DAE.STMT_IF(e1,sList,elseBranch,source);
          outStmts = elem::outStmts;
        then ();

      case DAE.STMT_WHILE(e1,sList,source)
        equation
          (outCache,e1) = prefixExpWork(outCache,env,inIH,e1,p);
          (outCache,sList) = prefixStatements(outCache,env,inIH,sList,p);
          elem = DAE.STMT_WHILE(e1,sList,source);
          outStmts = elem::outStmts;
        then ();

      case DAE.STMT_ASSERT(e1,e2,e3,source)
        equation
          (outCache,e1) = prefixExpWork(outCache,env,inIH,e1,p);
          (outCache,e2) = prefixExpWork(outCache,env,inIH,e2,p);
          (outCache,e3) = prefixExpWork(outCache,env,inIH,e3,p);
          elem = DAE.STMT_ASSERT(e1,e2,e3,source);
          outStmts = elem::outStmts;
        then ();

      case DAE.STMT_FAILURE(b,source)
        equation
          (outCache,b) = prefixStatements(outCache,env,inIH,b,p);
          elem = DAE.STMT_FAILURE(b,source);
          outStmts = elem::outStmts;
        then ();

      case DAE.STMT_RETURN(source)
        equation
          elem = DAE.STMT_RETURN(source);
          outStmts = elem::outStmts;
        then ();

      case DAE.STMT_BREAK(source)
        equation
          elem = DAE.STMT_BREAK(source);
          outStmts = elem::outStmts;
        then ();
    end match;
  end for;
  outStmts := Dangerous.listReverseInPlace(outStmts);
end prefixStatements;

protected function prefixElse "Prefix else statements.
  PART OF THE WORKAROUND FOR VALUEBLOCKS"
  input FCore.Cache cache;
  input FCore.Graph env;
  input InstanceHierarchy inIH;
  input DAE.Else elseBranch;
  input Prefix.ComponentPrefix pre;
  output FCore.Cache outCache;
  output DAE.Else outElse;
algorithm
  (outCache,outElse) := match (cache,env,inIH,elseBranch)
    local
      FCore.Cache localCache;
      FCore.Graph localEnv;
      InstanceHierarchy ih;
      DAE.Exp e;
      list<DAE.Statement> lStmt;
      DAE.Else el,stmt;

    case (localCache,_,_,DAE.NOELSE())
      then (localCache,DAE.NOELSE());

    case (localCache,localEnv,ih,DAE.ELSEIF(e,lStmt,el))
      equation
        (localCache,e) = prefixExpWork(localCache,localEnv,ih,e,pre);
        (localCache,el) = prefixElse(localCache,localEnv,ih,el,pre);
        (localCache,lStmt) = prefixStatements(localCache,localEnv,ih,lStmt,pre);
        stmt = DAE.ELSEIF(e,lStmt,el);
      then (localCache,stmt);

    case (localCache,localEnv,ih,DAE.ELSE(lStmt))
      equation
       (localCache,lStmt) = prefixStatements(localCache,localEnv,ih,lStmt,pre);
        stmt = DAE.ELSE(lStmt);
      then (localCache,stmt);
  end match;
end prefixElse;

public function makePrefixString "helper function for Mod.verifySingleMod, pretty output"
  input Prefix.Prefix pre;
  output String str;
algorithm
  str := matchcontinue(pre)
    case(Prefix.NOPRE()) then "from top scope";
    case _
      equation
        str = "from calling scope: " + printPrefixStr(pre);
      then str;
  end matchcontinue;
end makePrefixString;

public function prefixExpressionsInType
  input FCore.Cache inCache;
  input FCore.Graph inEnv;
  input InnerOuter.InstHierarchy inIH;
  input Prefix.Prefix inPre;
  input DAE.Type inTy;
  output FCore.Cache outCache;
  output DAE.Type outTy;
algorithm
  (outCache,outTy) := match inPre
    case Prefix.NOPRE()
      algorithm
        if System.getHasInnerOuterDefinitions() then
          (outCache,outTy) := prefixExpressionsInTypeWork(inCache,inEnv,inIH,Prefix.NOCOMPPRE(),inTy);
        else
          outCache := inCache;
          outTy := inTy;
        end if;
      then (outCache,outTy);
    case Prefix.PREFIX()
      algorithm
        (outCache,outTy) := prefixExpressionsInTypeWork(inCache,inEnv,inIH,inPre.compPre,inTy);
      then (outCache,outTy);
  end match;
end prefixExpressionsInType;

protected function prefixExpressionsInTypeWork
  input FCore.Cache inCache;
  input FCore.Graph inEnv;
  input InnerOuter.InstHierarchy inIH;
  input Prefix.ComponentPrefix inPre;
  input DAE.Type inTy;
  output FCore.Cache outCache;
  output DAE.Type outTy;
algorithm
  (outCache, outTy) := matchcontinue(inCache, inEnv, inIH, inPre, inTy)
    // don't do this for MetaModelica!
    case (_, _, _, _, _)
      equation
        true = Config.acceptMetaModelicaGrammar();
      then
       (inCache, inTy);

    else
      equation
        (outTy, (outCache, _, _, _)) = Types.traverseType(inTy, (inCache, inEnv, inIH, inPre), prefixArrayDimensions);
      then
        (outCache, outTy);
  end matchcontinue;
end prefixExpressionsInTypeWork;

protected function prefixArrayDimensions
"@author: adrpo
 this function prefixes all the expressions in types to be found by the back-end or code generation!"
  input DAE.Type ty;
  input tuple<FCore.Cache,FCore.Graph,InnerOuter.InstHierarchy,Prefix.ComponentPrefix> tpl;
  output DAE.Type oty = ty;
  output tuple<FCore.Cache,FCore.Graph,InnerOuter.InstHierarchy,Prefix.ComponentPrefix> otpl;
algorithm
  (oty,otpl) := match (oty,tpl)
    local
      DAE.TypeSource ts;
      FCore.Cache cache1,cache2;
      FCore.Graph env;
      InnerOuter.InstHierarchy ih;
      Prefix.ComponentPrefix pre;
      DAE.Dimensions dims;

    case (DAE.T_ARRAY(),(cache1, env, ih, pre))
      equation
        (cache2, dims) = prefixDimensionsWork(cache1, env, ih, pre, oty.dims);
        oty.dims = dims;
      then
        (oty,if referenceEq(cache1,cache2) then tpl else (cache2, env, ih, pre));

    else (oty,tpl);

  end match;
end prefixArrayDimensions;

public function prefixDimensions
  input FCore.Cache inCache;
  input FCore.Graph inEnv;
  input InnerOuter.InstHierarchy inIH;
  input Prefix.Prefix inPre;
  input DAE.Dimensions inDims;
  output FCore.Cache outCache;
  output DAE.Dimensions outDims;
algorithm
  (outCache,outDims) := match inPre
    case Prefix.NOPRE()
      algorithm
        if System.getHasInnerOuterDefinitions() then
          (outCache,outDims) := prefixDimensionsWork(inCache,inEnv,inIH,Prefix.NOCOMPPRE(),inDims);
        else
          outCache := inCache;
          outDims := inDims;
        end if;
      then (outCache,outDims);
    case Prefix.PREFIX()
      algorithm
        (outCache,outDims) := prefixDimensionsWork(inCache,inEnv,inIH,inPre.compPre,inDims);
      then (outCache,outDims);
  end match;
end prefixDimensions;

protected function prefixDimensionsWork
  input FCore.Cache inCache;
  input FCore.Graph inEnv;
  input InnerOuter.InstHierarchy inIH;
  input Prefix.ComponentPrefix inPre;
  input DAE.Dimensions inDims;
  output FCore.Cache outCache;
  output DAE.Dimensions outDims;
algorithm
  (outCache,outDims) := matchcontinue (inCache, inEnv, inIH, inPre, inDims)
    local
      DAE.Exp e;
      DAE.Dimensions rest, new;
      DAE.Dimension d;
      FCore.Cache cache;

    case (_, _, _, _, {}) then (inCache, {});

    case (_, _, _, _, DAE.DIM_EXP(exp=e)::rest)
      equation
        (cache, e) = prefixExpWork(inCache, inEnv, inIH, e, inPre);
        (cache, new) = prefixDimensionsWork(cache, inEnv, inIH, inPre, rest);
      then
        (cache, DAE.DIM_EXP(e)::new);

    case (_, _, _, _, d::rest)
      equation
        (cache, new) = prefixDimensionsWork(inCache, inEnv, inIH, inPre, rest);
      then
        (cache, d::new);
  end matchcontinue;
end prefixDimensionsWork;

public function isNoPrefix
  input Prefix.Prefix inPrefix;
  output Boolean outIsEmpty;
algorithm
  outIsEmpty := match(inPrefix)
    case Prefix.NOPRE() then true;
    else false;
  end match;
end isNoPrefix;

public function prefixClockKind "Add the supplied prefix to the clock kind"
  input FCore.Cache inCache;
  input FCore.Graph inEnv;
  input InnerOuter.InstHierarchy inIH;
  input DAE.ClockKind inClkKind;
  input Prefix.ComponentPrefix inPrefix;
  output FCore.Cache outCache;
  output DAE.ClockKind outClkKind;
algorithm
  (outCache, outClkKind) := match (inCache, inEnv, inIH, inClkKind, inPrefix)
    local
      DAE.Exp e,resolution,interval,method;
      DAE.ClockKind clkKind;
      FCore.Cache cache;
      FCore.Graph env;
      InstanceHierarchy ih;
      Prefix.ComponentPrefix p;

    // clock kinds
    case (cache, env, ih, DAE.INFERRED_CLOCK(), p)
      then (cache, inClkKind);

    case (cache, env, ih, DAE.INTEGER_CLOCK(e, resolution), p)
      equation
        (cache, e) = prefixExpWork(cache, env, ih, e, p);
        (cache, resolution) = prefixExpWork(cache, env, ih, resolution, p);
        clkKind = DAE.INTEGER_CLOCK(e, resolution);
      then
        (cache, clkKind);

    case (cache, env, ih, DAE.REAL_CLOCK(e), p)
      equation
        (cache, e) = prefixExpWork(cache, env, ih, e, p);
        clkKind = DAE.REAL_CLOCK(e);
      then
        (cache, clkKind);

    case (cache, env, ih, DAE.BOOLEAN_CLOCK(e, interval), p)
      equation
        (cache, e) = prefixExpWork(cache, env, ih, e, p);
        (cache, interval) = prefixExpWork(cache, env, ih, interval, p);
        clkKind = DAE.BOOLEAN_CLOCK(e, interval);
      then
        (cache, clkKind);

    case (cache, env, ih, DAE.SOLVER_CLOCK(e, method), p)
      equation
        (cache, e) = prefixExpWork(cache, env, ih, e, p);
        (cache, method) = prefixExpWork(cache, env, ih, method, p);
        clkKind = DAE.SOLVER_CLOCK(e, method);
      then
        (cache, clkKind);

  end match;
end prefixClockKind;

public function getPrefixInfo
  input Prefix.Prefix inPrefix;
  output SourceInfo outInfo;
algorithm
  outInfo := match inPrefix
    case Prefix.PREFIX(compPre = Prefix.PRE(info = outInfo)) then outInfo;
    else Absyn.dummyInfo;
  end match;
end getPrefixInfo;

annotation(__OpenModelica_Interface="frontend");
end PrefixUtil;
