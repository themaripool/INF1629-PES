﻿<%
  dofile"dao.lua"
  dofile"xmlgenerator.lua"
  local cfg = dofile"config.lua"
  local conf = dao.get_conference_json(cgilua.QUERY.conference)  
  local d = dao.split_string(conf, "<br/>")
  c = dao.separate_in_key_value(d)
  --for k,v in pairs(c) do
  	--cgilua.print('<p> chave '..k..' valor '..v..'</p>\n')
  --end
  local l = xmlgenerator.createXML(cgilua.QUERY.conference)
  if l ~= nil then cgilua.print('<p>'..l..'</p>') end
  
  -- --ATUALIZAR O NUMERO DE CITACOES DO PAPER (20 ULTIMOS ATUALIZADOS) 1 VEZ X DIA
	-- local update_most_cited = dofile(cfg.file_most_cited)
%>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=unicode">
	<title>
		<% 	cgilua.print(string.format("%s %s: %s, %s",
			c["name_conference"], c["year"], c["city"], c["country"]))
		%>
	</title>
	<!-- google api -->
	<script>
	  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
	  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
	  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
	  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

	  ga('create', 'UA-69457653-1', 'auto');
	  ga('send', 'pageview');

	</script>
	<!-- end google api -->
	<!--
	jQuery plugin: Tablesorter 2.0 - Sort table using a link outside the table
	-->
	<link rel="stylesheet" href="../themes/blue/style.css" type="text/css" id="" media="print, projection, screen" />
	<script type="text/javascript" src="../js/jquery-latest.js"></script>
	<script type="text/javascript" src="../js/jquery.tablesorter.js"></script>
	
	<!-- google chart-->
	<script type="text/javascript" src="https://www.google.com/jsapi"></script>

</head>

<body>
<table width="100%" align=left>
<tr>
 <%
  --header modified to add the capes logo 4-14-2016 
 local title_string = string.format("<td><h1><a href=http://%s>%s</a> - Workshop de Transparência em Sistemas %s: %s, %s </h1></td>",
   'wtrans.inf.puc-rio.br', c["name_conference"], c["year"], c["city"], c["country"])
 local capes_string = string.format("<td width='5' align=right><img border='0' src='"..cfg["file_capes_logo"].."'></td>")
 if c["year"] == '2013' or c["year"] == '2015' then
	cgilua.print("<H2>"..title_string.."<p>"..capes_string.."</H2>")
else
	cgilua.print("<H2>"..title_string.."</H2>")
end
%>
</tr>
</table>
		
  <hr>
  <%
   local anais_string = string.format("Anais do %s - Workshop de Transparência "
     .."em Sistemas, %s, %s, %s %s, %s", c["name_conference"], c["city"],
     c["country"], c["month"], c["days"], c["year"], c["ISSN"], c["ISBN"], c["year"])

   cgilua.print(string.format("%s (Ed.): "..anais_string..".<p align=right><a href='"..cfg["file_paper_home"].."' align=right>voltar</a><p>", c["editor"]))

  cgilua.print(string.format(
     "<pre>@proceedings{<a href='"..cfg["file_wtrans_home"].."'>WTRANSArtigos</a>: %s,<br>&nbsp;&nbsp;"
       .."editor = {%s},<br>&nbsp;&nbsp;"
       .."title = {"..anais_string.."},<br>&nbsp;&nbsp;"
       .."publisher = { },<br>&nbsp;&nbsp;"
		.."ISSN = {%s},<br>&nbsp;&nbsp;"
       .."ISBN = {%s},<br>&nbsp;&nbsp;"
       .."year = {%s}<br>"
     .."}<br></pre>", c["name_conference"], c["editor"], c["ISSN"], c["ISBN"], c["year"]))
	
	
	--get papers
    local gpapers, ifk, ifv, elsev = dao.separate_in_key_value(dao.list_papers_by_conference(cgilua.QUERY.conference))
    -- PRINT TEXT FOR PAPERS, DOWNLOADS, CITATIONS AND DIV FOR CHART
	local papers = ''
	local downloads = ''
	local citations = ''
	local labels = ''
	local i = 1
	local gpapers = dao.list_papers_by_conference(cgilua.QUERY.conference)
	gpaperstable = {}
	for k, v in pairs(gpapers) do
		local x = dao.split_string(v, "<br/>")
		local p = dao.separate_in_key_value(x)
		if papers == '' then
			--cgilua.print('<p> ENTREI NO FOR KV IF PAPERS DO GPAIRS </p>')
			if p["paper_title"] == nil then
				--cgilua.print('<p> ENTREI NO FOR KV IF PAPERS IF DO GPAIRS </p>')
				papers = " "
			else
				--cgilua.print('<p> ENTREI NO FOR KV IF PAPERS ELSE DO GPAIRS </p>')
				papers = p["paper_title"]
			end
		else
			--cgilua.print('<p> ENTREI NO FOR KV ELSE PAPERS DO GPAIRS </p>')
			if p["paper_title"] ~= nil then
				--cgilua.print('<p> ENTREI NO FOR KV ELSE PAPERS IF DO GPAIRS </p>')
				papers = papers .. ',' .. p["paper_title"]
			end
		end
		if downloads == '' then
		--cgilua.print('<p> ENTREI NO FOR KV IF downloads DO GPAIRS </p>')
			if p["num_downloads"] == nil then
			--cgilua.print('<p> ENTREI NO FOR KV IF downloads IF DO GPAIRS </p>')
				downloads = " "
			else
			--cgilua.print('<p> ENTREI NO FOR KV IF downloads ELSE DO GPAIRS </p>')
				downloads = p["num_downloads"]
			end
		else
		--cgilua.print('<p> ENTREI NO FOR KV ELSE downloads DO GPAIRS </p>')
			if p["num_downloads"] ~= nil then
			--cgilua.print('<p> ENTREI NO FOR KV ELSE downloads IF DO GPAIRS </p>')
				downloads = downloads .. ',' .. p["num_downloads"]
			end
		end	
		if citations == '' then
		--cgilua.print('<p> ENTREI NO FOR KV IF citations DO GPAIRS </p>')
			if p["num_citations"] == nil then
			--cgilua.print('<p> ENTREI NO FOR KV IF citations if DO GPAIRS </p>')
				citations = " "
			else
			 --cgilua.print('<p> ENTREI NO FOR KV IF citations else DO GPAIRS </p>')
				citations = p["num_citations"]
			end			
		else
		--cgilua.print('<p> ENTREI NO FOR KV else citations DO GPAIRS </p>')
			if p["num_citations"] ~= nil then
			--cgilua.print('<p> ENTREI NO FOR KV else citations if DO GPAIRS </p>')
				citations = citations .. ',' .. p["num_citations"]
			end
		end
		
		if labels == '' then
		--cgilua.print('<p> ENTREI NO FOR KV IF labels DO GPAIRS </p>')
			if p["file_name"] == nil then
			-- cgilua.print('<p> ENTREI NO FOR KV IF labels if DO GPAIRS </p>')
				labels = " "
			else
			--cgilua.print('<p> ENTREI NO FOR KV IF labels else DO GPAIRS </p>')
				labels = p["file_name"]
			end	
		else
		-- cgilua.print('<p> ENTREI NO FOR KV else labels DO GPAIRS </p>')
			if p["file_name"] ~= nil then
			--cgilua.print('<p> ENTREI NO FOR KV else labels if DO GPAIRS </p>')
				labels = labels .. ',' .. p["file_name"]
			end
		end
		i = i + 1
	end

	cgilua.print("<input type= 'hidden' id ='papers' value = '"..papers.."'>")
	cgilua.print("<input type= 'hidden' id ='labels' value = '"..labels.."'>")
	cgilua.print("<input type= 'hidden' id ='downloads' value = '"..downloads.."'>")
	cgilua.print("<input type= 'hidden' id ='citations' value = '"..citations.."'>")
	cgilua.print("<div id='chart_div'></div>")
	
--	print tables of sessions of papers
	local gpapers = dao.list_papers_by_conference(cgilua.QUERY.conference)
	for k, v in pairs(gpapers) do
			local x = dao.split_string(v, "<br/>")
			local p = dao.separate_in_key_value(x)
				local i = 1 
				old_paper_session = ""
				-- print session if it changed
				if p["paper_session"] ~= old_paper_session then
					-- Close old table if it changed
					if old_paper_session ~= '' then
						cgilua.print('</tbody></table>')
					end
					
					-- NEW TITLE
					cgilua.print("<H2>"..p["paper_session"].."</H2>")
					old_paper_session = p["paper_session"]
							
					-- Open new table if it changed
					cgilua.print('<table cellspacing=\"1\" class=\"tablesorter\">')
					cgilua.print('<thead>')
							cgilua.print('<tr>')
								cgilua.print('<th>Paper&nbsp</th>')
								cgilua.print('<th>Citações&nbsp</th>')
								cgilua.print('<th>Downloads&nbsp</th>')
							cgilua.print('</tr>')
						cgilua.print('</thead>')
						cgilua.print('<tbody>')
				end
				
				-- number of downloads
				
				local downloads = 0
					downloads = p["num_downloads"]
				local  citations = 0
					citations = p["num_citations"]
					--end	
				local scholar_url = require"scholar/scholar_string_cleaner".montaUrl(
											cfg.scholar_base_url, p["paper_title"], p["author"])
				
				-- print each paper published IN A SORTED TABLE
				cgilua.print('<tr>')
						cgilua.print('<td>')
							cgilua.print(string.format(
							"<div><h2><b>%s</b>.</h2></div>", p["paper_title"] or ""
							))
							cgilua.print(string.format(
							-- "<font size='2'>%s,".." %s. "..anais_string..", pp %s</font><br>", p["author"], p["add_author"], p["page"] or ""
							"<font size='2'>%s"..", %s</font><br>", p["author"], p["add_author"] or ""
							))
							cgilua.print('[')
							cgilua.print(string.format(
							"<a href='artigos/artigos_%s/%s' target='_blank' onClick=\"ga('send', 'event', { eventCategory: 'Papers', eventAction: 'Download', eventLabel: '%s'} );\" >pdf</a>", p["name_conference"], p["file_name"], p["file_name"] or ""
							))
							cgilua.print('] - ')
							cgilua.print('[')
							cgilua.print(string.format(
							"<a href='%s' target='_blank'>scholar</a>", scholar_url or ""
							))
							cgilua.print(']')
							cgilua.print(string.format("<br><br>"))
							
						cgilua.print('</td>')	
						cgilua.print('<td>')
							cgilua.print(string.format("<font face='Arial' size='2'>Citado por: %s </font>",citations))
						cgilua.print('</td>')
						cgilua.print('<td>')
							cgilua.print(string.format("<font face='Arial' size='2' data-analytics-label='%s' class='downloads-number' old-downloads-number='%s'>", p["file_name"], downloads))
							cgilua.print("Downloads: ...")
							cgilua.print("</font>")
						cgilua.print('</td>')
				cgilua.print('</tr>')
				
				i = i + 1

	end
	--
	--LAST TABLE
	-- Close old table if it changed
--	if old_paper_session ~= '' then
--		cgilua.print('</tbody></table>')
--	end
  %>
  -- &nbsp;&nbsp;<a href="<%=cfg["file_paper_home"]%>">voltar</a>
  </hr>
  </table>
  </tr>
</body>


  <script type="text/javascript">
		function putDownloadsNumbersOnTable(downloadsJson) {
			$(".downloads-number").each(function(){
				var label = $(this).attr("data-analytics-label");
				var oldDownloadsNumber = $(this).attr("old-downloads-number");
				var downloadsNumber = downloadsJson[label] || 0;
				var sumDownload = parseInt(downloadsNumber)+parseInt(oldDownloadsNumber);
				$(this).text("Downloads: " + sumDownload );
			});
		}


		// Draw google chart
		function initGoogleCharts(downloadsJson) {
			var drawer = new PapersChartDrawer(downloadsJson);
			google.load('visualization', '1', {packages: ['corechart', 'bar']});
			google.setOnLoadCallback(drawer.drawAnnotations);
		}

		function PapersChartDrawer(downloadsJson) {
			var OPTIONS = {
				title: 'Downloads e Cita��es',
				annotations: {
					alwaysOutside: true,
					textStyle: {
					fontSize: 14,
					color: '#000',
					auraColor: 'none'
					}
				},
				hAxis: {
					title: 'Papers',
					format: '',
					viewWindow: {
					min: [7, 30, 0],
					max: [17, 30, 0]
					}
				},
				vAxis: {
					title: 'Ocorr�ncias'
				}
			};

			this.drawAnnotations = function() {
				//pegar papers downloads e citations do HTML
				var array_papers = (document.getElementById('papers').value).split(",");
				var array_labels = (document.getElementById('labels').value).split(",");
				var array_citations = (document.getElementById('citations').value).split(",");
				var array_old_downloads = (document.getElementById('downloads').value).split(",");
				var array_downloads = array_downloads_from_json(array_labels, downloadsJson);
				var array_total_downloads = sumArray(array_downloads, array_old_downloads);
				var data = buildDataTableWith(array_papers, array_total_downloads, array_citations);
				var chart = new google.visualization.ColumnChart(document.getElementById('chart_div'));
				chart.draw(data, OPTIONS);
			};

			function buildDataTableWith(array_papers, array_downloads, array_citations) {
				var data = new google.visualization.DataTable();
				data.addColumn('string', 'xAxisNames');
				data.addColumn('number', 'Downloads');
				data.addColumn('number', 'Cita��es');
				//criar data json para o gerador de grafico
				var jsonNodes = [];
				for	(index = 0; index < array_papers.length; index++) {
					var paperNumber = index+1;
					var itemNode = []
					itemNode.push({v: "", f: array_papers[index]});
					itemNode.push(parseInt(array_downloads[index]));
					itemNode.push(parseInt(array_citations[index]));
					jsonNodes.push(itemNode);
				}
				data.addRows(jsonNodes);
				return data;
			}

			function array_downloads_from_json(labels, downloadsJson) {
				var downloads = [];
				for(var labeli in labels) {
					var label = labels[labeli];
					downloads.push(downloadsJson[label] || 0);
				}
				return downloads;
			}

			function sumArray(a, b) {
			    var c = [];
			    for (var i = 0; i < Math.max(a.length, b.length); i++) {
			        c.push((parseInt(a[i]) || 0) + (parseInt(b[i]) || 0));
			    }
			    return c;
			}

		}
	</script>

	<!-- ###  Main script ### -->
  <script type="text/javascript">
		(function() {
			var response = $.ajax({
				url: "http://wtrans-analytics.herokuapp.com/downloads.json",
				method: "get",
				async: false
			});

			var json = JSON.parse(response.responseText);
			initGoogleCharts(json);

			$(function() {
				putDownloadsNumbersOnTable(json);
				$("table").tablesorter(); // Setup sorting on the tables
			});
		}());
	</script>

</html>
