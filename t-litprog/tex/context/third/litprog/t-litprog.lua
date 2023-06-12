if not modules then
   modules = {}
end

modules ['t-litprog'] = {
    version   = 1.1,
    comment   = "Literate Programming in ConTeXt",
    author    = "PerceptiSys Ltd (Stephen Gaito)",
    copyright = "PerceptiSys Ltd (Stephen Gaito)",
    license   = "MIT License"
}

local tConcat = table.concat
local tInsert = table.insert

local context = context
local verbatim = context.verbatim

local thirddata   = thirddata or {}
thirddata.litProg = thirddata.litProg or {}
local litProg     = thirddata.litProg

local function createFixLitProgs(theLitProgsName)
  -- \let\oldstart{{=theLitProgsName}}=\start{{=theLitProgsName}}
  -- \def\start{{=theLitProgsName}}#1{
  --   \oldStart{{=theLitProgsName}}  
  -- }
  local theTeX = {}
  tInsert(theTeX, '\\let\\oldStart')
  tInsert(theTeX, theLitProgsName)
  tInsert(theTeX, '=\\start')
  tInsert(theTeX, theLitProgsName)
  tInsert(theTeX, '\\def\\start')
  tInsert(theTeX, theLitProgsName)
  tInsert(theTeX, '#1{\\color[gray]{{\\bf ')
  tInsert(theTeX, theLitProgsName)
  tInsert(theTeX, '}: #1}\\oldStart')
  tInsert(theTeX, theLitProgsName)
  tInsert(theTeX, '}')
  local theTeXStr = tConcat(theTeX)
  tex.print(theTeXStr)
  return theTeXStr
end

litProg.createFixLitProgs = createFixLitProgs

litProg.cCodeWords = {}

local function addCCodeIndex(wordToIndex)
  litProg.cCodeWords[wordToIndex] = true
end

litProg.addCCodeIndex = addCCodeIndex

local function checkCCodeIndex(wordToCheck)
  if litProg.cCodeWords[wordToCheck] then
    tex.sprint('\\index{'..wordToCheck..'} ')
  end
end

litProg.checkCCodeIndex = checkCCodeIndex

---------------------------------------------------------------------
-- do the monkey patch!
--
-- We monkey patch the verbatim.CppSnippetIdent function as "defined" by
-- the context-highlight / t-hightlight-cpp.lua file. We do this to wrap
-- our additional indexing functionality around the existing
-- CppSnippetIdent function.

local origCppSnippetIdent = verbatim.CppSnippetIdent

local function mpCppSnippetIdent(s)
  checkCCodeIndex(s)
  origCppSnippetIdent(s)
end

verbatim.CppSnippetIdent = mpCppSnippetIdent
