-- load connection file
require("contador")


-- enable contador and assert use
local assert, contador, string = assert, contador, string
local error, type, tostring = error, type, tostring
local require = require
local pairs = pairs
local print = print

--debug
local _G = _G

module("dao")

-- Executes a query in the database specified by
-- the contador.lua file.
-- @param sql statement to be executed
-- @return iterator function containing tuples
local function query(stmt)
  local con = contador.db_connect()
  local res, err = con:execute(stmt)
  con:close()

  assert(res, "\n\nQuery:\n"..stmt.."\n\nErro:\n"..(err or "").."\n")

  -- insert query
  if type(res) == "number" then
    return res
  end

  -- return iterator function
  return function()
     -- "a" uses the database index in the lua table
     return res:fetch({},"a")
  end
end

-- Query function for retrieving all conferences ordered
-- by id.
-- @return iterator function containing tuples or nil
function get_conferences()
  local stmt = "select * from conferences order by id;"
  return query(stmt)
end

function get_conferences_json()
    -- tests the functions above
  local file = 'jsonConferences.json'
  local lines = lines_from(file)
  return lines

  -- print all line numbers and their contents
  --for k,v in pairs(lines) do
  --  print('line[' .. k .. ']', v)
  --end
end

function file_exists(file)
  local io = require("io")
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

-- get all lines from a file, returns an empty 
-- list/table if the file does not exist
function lines_from(file)
  local io = require("io")
  if not file_exists(file) then return {} end
  lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end

function object_from(file)
  local io = require("io")
  if not file_exists(file) then
    return {}
  end
  objects = {}
  objects = lines_from(file)
  result = {}
  countFor = 0
  countIf = 0
  countElseIf = 0
  countElse = 0
  i = 1
  j = 1
  while i <= #objects do
    countFor = countFor + 1
    if not string.match(objects[i], "}") and not string.match(objects[i], "%[") and not string.match(objects[i], "%]") then
      if result[j] == nil then
        result[j] = objects[i]
      else 
        result[j] = result[j]..objects[i]
      end
      countIf = countIf + 1
    else 
      if string.match(objects[i], "}") then
        if result[j] == nil then
          result[j] = "}"
        else 
          result[j] = result[j].."}"
        end
        countElseIf = countElseIf + 1
        j = j + 1
      else 
        result[j] = result[j]
        countElse = countElse + 1
      end
    end
   i = i + 1
  end
  return result
end
-- end

-- Query function for retrieving one specific conference.
-- @param conference: conference name
-- @return table containing conference information
function get_conference_json(conference)
  local file = 'jsonConferences.json'
  local allConferences = object_from(file)
  local result = nil
  for k,v in pairs(allConferences) do
    if string.match(v, conference) then
      result = v
    end
  end
  return result;
  --return allConferences
end

-- Query function for retrieving all papers from a
-- specific conference.
-- @param conference: conference name
-- @return iterator function containing tuples or nil
function list_papers_by_conference(conference)
  local stmt = "select * from papers where name_conference = '"..conference
    .."' order by paper_session;"
  return query(stmt)
end

-- Query function for retrieving one paper by id.
-- @param paper_id: paper id
-- @return iterator function containing tuples or nil
function get_paper_by_id(paper_id)
  local stmt = "select * from papers where id="..paper_id..";"
  return query(stmt)
end

-- Query function for retrieving all papers.
-- @return iterator function containing tuples or nil
function get_all_papers()
  --local stmt = "select id, paper_title, author from papers;"
  local stmt = "select * from papers order by name_conference;"
  return query(stmt)
end

-- Query function for retrieving 20 papers ordered by date of citations (ASC).
-- @return iterator function containing tuples or nil
function get_papers_by_date_citations(num_papers)
  local stmt = "select * from papers order by date_citations ASC limit "..num_papers..";"
  --local stmt = "SELECT * FROM ( "..
	--			   "SELECT * FROM papers ORDER BY date_citations ASC "..
		--		") AS t1 "..
			--	"GROUP BY file_name ORDER BY date_citations ASC LIMIT " .. num_papers..";"
  return query(stmt)
end
--Get paper with last citation date
function get_last_citation_paper()
  local stmt = "select * from papers order by date_citations DESC limit 1;"
  return query(stmt)
end

-- Query function for retrieving most cited papers ordered by citations (DESC).
-- @return iterator function containing tuples or nil
function get_papers_most_cited()
  local stmt = "select * from papers where num_citations > 0 order by num_citations DESC;"
  return query(stmt)
end

function insert_conference(c)
  local stmt = string.format("insert into conferences (name_conference, url,"
  .."editor, ISBN, month, days, year, country, city) VALUES ('%s','%s','%s',"
  .."'%s','%s','%s','%s','%s','%s')", c.name, c.url, c.editor, c.isbn,
  c.month, c.days, c.year, c.country, c.city)

--  return stmt
  return query(stmt)
end

function insert_paper(p)
  local stmt = string.format("insert into papers (paper_title, file_name,"
  .."key_words, language,author, add_author, abstract, paper_session, page,"
  .."name_conference) VALUES ('%s','%s','%s','%s','%s','%s','%s','%s','%s','%s')",
  p.paper_title, p.file_name, p.key_words, p.language, p.author, p.add_author,
  p.abstract, p.paper_session, p.page, p.conference)

--  return stmt
  return query(stmt)
end
--]]


function get_downloads_number(file_name)
	local stmt = string.format("SELECT * FROM `papers` WHERE `file_name` = '%s'", file_name)
	return query(stmt)
end

function add_download(file_name)
	local stmt = string.format("UPDATE papers SET num_downloads = num_downloads + 1 WHERE file_name = '%s'", file_name)
	return query(stmt)
end

-- function add_citation(file_name, num_citations)
		-- local stmt = string.format("UPDATE papers SET num_citations = "..num_citations.." , date_citations = CURRENT_TIMESTAMP WHERE file_name = '%s'", file_name)
		-- return query(stmt)
-- end