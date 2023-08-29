<cfoutput>
<cfset sdtatual = dateformat(now(),"YYYYMMDDHH")>
<cfset sdtarquivo = dateformat(now(),"YYYYMMDDHH")>
<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>

<cfif isDefined("Form.Submit")>
	<cfif isDefined("Form.acao") And (Form.acao is 'Anexar')>
		<cffile action="upload" filefield="arquivopdf" destination="#GetDirectoryFromPath(gettemplatepath())#Dados\Proc_Lote\" nameconflict="overwrite" accept="application/pdf">
	</cfif>
	<cfif isDefined("Form.acao") And (Form.acao is 'Excluir')>
		<cffile action="delete" file="#GetDirectoryFromPath(gettemplatepath())#Dados\Proc_Lote\#form.vCodigo#">
	</cfif>
</cfif>
<cfif not isDefined("Form.Submit")>
	<cfdirectory name="qList" filter="*.*" sort="name desc" directory="#GetDirectoryFromPath(gettemplatepath())#Dados\Proc_Lote\">
	<cfloop query= "qList">
	    <cffile action="delete" file="#GetDirectoryFromPath(gettemplatepath())#Dados\Proc_Lote\#name#">
	</cfloop>
    <cffile action="upload" filefield="arquivo" destination="#GetDirectoryFromPath(GetTemplatePath())#Dados\Proc_Lote" nameconflict="overwrite">
</cfif>
<cfdirectory name="qList" filter="*.csv" sort="name desc" directory="#GetDirectoryFromPath(gettemplatepath())#Dados\Proc_Lote\">
<cffile action="read" file="#GetDirectoryFromPath(gettemplatepath())#Dados\Proc_Lote\#qList.name#" variable="sdados" charset="utf-8">

<cfset CountVar = len(sdados)> 
<cfset contador = 1>
<cfset qtdproc = 0>
<cfset qtdcsv = 0>
<cfset sinic = 30>
<cfset sfim = 0>
<cfset stam = 0>
<cfset smeio = findOneOf(';', sdados, sinic + 1)>
<cfset auxdadosproc = "">
<cfset auxdadosnproc = "">
<cfset qtdnproc = 0>
<cfset auxdados = "Unidade   NºInspeção   Grupo   Item" & CHR(13)>
<cfset arqloteent = ArrayNew(1)>
<cfset arqlotesai = ArrayNew(1)>
 <cfloop condition = "CountVar gt #sfim#"> 
    	<cfswitch expression="#contador#">
	  <cfcase value="1">
	       <cfset stam = smeio - sinic>
		   <cfset unidade = mid(sdados,sinic, stam)>
		   <cfset unidade = trim(unidade)>
		   <cfset qtdcsv = qtdcsv + 1>
		   <cfset sinic = smeio + 1>
<!--- 		   unid: #unidade#  <br>
		   sinic: #sinic#<br>
		   smeio: #smeio#<br>
		   =====================<br> --->
	  </cfcase>
	  <cfcase value="2">
	      <cfset stam = smeio - sinic>
		  <cfset inspecao = mid(sdados, sinic, stam)>
		  <cfset inspecao = trim(inspecao)>
		  <cfset sinic = smeio + 1>
		<!---   insp: #inspecao#  <br>
		  sinic: #sinic#<br>
		  smeio: #smeio#<br>
		  =====================<br> --->
	  </cfcase>
	  <cfcase value="3">
          <cfset stam = smeio - sinic>
		  <cfset grupo = mid(sdados, sinic, stam)>
		  <cfset grupo = trim(grupo)>
		  <cfset sinic = smeio + 1>
<!--- 		  grupo: #grupo#  <br>
		  sinic: #sinic#<br>
		  smeio: #smeio#<br>
		  =====================<br> --->
	   </cfcase>
	  <cfcase value="4"> 
	      <cfset smeio = smeio - 10>
		  <cfset stam = smeio - sinic>
		  <cfset item = mid(sdados, sinic, stam)>
		  <cfset item = trim(item)>
		  <cfset sinic = smeio>
		<!---   item: #item#  <br>
		  stam: #stam#<br>
		  sinic: #sinic#<br>
		  smeio: #smeio#<br>
		  <cfset gil = gil>
		  =====================<br> --->
	  </cfcase>		  
	</cfswitch>
	<cfset contador = contador + 1>
	<cfset smeio = findOneOf(';', sdados, sinic + 1)>
	<cfif smeio eq 0>
	  <cfset item = mid(sdados, (sinic), CountVar)>
	  <cfset item = trim(item)>
	 <cfset sfim = CountVar + 1>
	</cfif>
<cfif (contador eq 5) or (smeio eq 0)>
   <cfset ArrayAppend(arqloteent, "#unidade##inspecao#G#grupo#I#item#")>
   <cfset contador = 1>
</cfif>
</cfloop>
 <!--- Classificar o array de saida --->
	 <cfset myList = ArrayToList(arqloteent, ",")>
     <cfset isSuccessful = ArraySort(arqloteent, "textnocase")> 
 <!--- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ --->
 <cfset aux_posarea = "">
 <cfset aux_posnomearea = "">
 <cfif isDefined("Form.acao") And (Form.acao is 'Salvar')>
 <!--- Rotina para update, insert, anexos e envi de e-mail  --->
	 <cfloop from="1" to="#ArrayLen(arqloteent)#" index="i">
	      <cfset dbunid = #left(arqloteent[i],8)#>
		  <cfset dbinsp = #mid(arqloteent[i],9,10)#>
		  <cfset sinic = findOneOf('G', arqloteent[i])>
		  <cfset sinic = sinic + 1>
		  <cfset sfim = findOneOf('I', arqloteent[i], sinic)>
		  <cfset stam = sfim - sinic>
		  <cfset dbgrupo = trim(mid(arqloteent[i],sinic,stam))>
		  <cfset sinic = sfim + 1>
		  <cfset dbitem = trim(mid(arqloteent[i],sinic,len(arqloteent[i])))>
		  <cfset sinic = 0>
		  <cfset sfim = 0>
		 
		 <!--- Definir os dados do Pos_Area e Pos_NomeArea --->
		 <cfif form.frmResp eq 21 or form.frmResp eq 28>
			<!---  --->
			<cfset auxSE = left(dbinsp,2)>
			<cfset scia_se = auxSE>
			<cfif auxSE eq '03' or auxSE eq '16' or auxSE eq '26' or auxSE eq '06' or auxSE eq '75' or auxSE eq '28' or auxSE eq '65' or auxSE eq '05'> <!--- ACR;GO;RO;AM;TO;PA;RR;AP --->
				<cfset scia_se = '10'>	<!--- BSB --->
			<cfelseif auxSE eq '08' or auxSE eq '14'>   <!--- BA; ES --->
				<cfset scia_se = '20'> <!--- MG --->
			<cfelseif auxSE eq '04' or auxSE eq '12' or auxSE eq '18' or auxSE eq '30' or auxSE eq '34' or auxSE eq '60' or auxSE eq '70'> <!--- AL; CE; MA; PB; PI; RN; SE --->
				<cfset scia_se = '32'> <!--- PE --->
			<cfelseif auxSE eq '68' or auxSE eq '64'> <!--- SC;RS --->
				<cfset scia_se = '36'>	<!--- PR --->
			<cfelseif auxSE eq '50'>   <!--- RJ --->
				<cfset scia_se = '72'> <!--- SPM --->
			<cfelseif auxSE eq '22' OR auxSE eq '24'>   <!--- MS; MT --->
				<cfset scia_se = '74'> <!--- SPI --->				 					 				 
			</cfif>	
			<!---  --->	 
			<cfquery name="rsSCIA" datasource="#dsn_inspecao#">
			 SELECT DISTINCT Ars_Codigo, Ars_Sigla, Ars_Descricao, Ars_Email
			 FROM Areas WHERE Ars_Status = 'A' AND (Left(Ars_Codigo,2) = '#scia_se#') and (Ars_Sigla Like '%/SCIA%' OR Ars_Sigla Like '%DCINT/GCOP/SGCIN/SCIA')
			 ORDER BY Ars_Sigla
			</cfquery>				
<!--- 			<cfquery name="rsarea" datasource="#dsn_inspecao#">
			 SELECT Ars_Codigo, Ars_Sigla
			 FROM Areas 
			 WHERE (Ars_Sigla Like '%SCOI%' OR Ars_Sigla Like '%DCINT/GCOP/SGCIN/SCOI') AND (Ars_Status = 'A') AND (Left([Ars_Codigo],2)) = '#left(dbunid,2)#'
			</cfquery> --->
			<cfset aux_posarea = #rsSCIA.Ars_Codigo#>
			<cfset aux_posnomearea = #rsSCIA.Ars_Sigla#>
		<cfelseif form.frmResp eq 3 or form.frmResp eq 10 or form.frmResp eq 13> 
			<cfquery name="rsAreaAtu" datasource="#dsn_inspecao#">
			SELECT Pos_Area, Pos_NomeArea 
			FROM ParecerUnidade 
			WHERE (Pos_Unidade = '#dbunid#') AND (Pos_Inspecao = '#dbinsp#') AND (Pos_NumGrupo = #dbgrupo#) AND (Pos_NumItem = #dbitem#)
			</cfquery>
			<cfset aux_posarea = #rsAreaAtu.Pos_Area#>
			<cfset aux_posnomearea = #rsAreaAtu.Pos_NomeArea#>
		<cfelseif form.frmResp eq 15>		
			<cfquery name="rsUnidade" datasource="#dsn_inspecao#">
				SELECT Und_Descricao
				FROM Unidades
				WHERE Und_Codigo = '#dbunid#'
			</cfquery>
			<cfset aux_posarea = #dbunid#>
			<cfset aux_posnomearea = #rsUnidade.Und_Descricao#>			
		<cfelse>	
			<cfquery name="rsAreacs" datasource="#dsn_inspecao#">
			 SELECT Ars_Codigo, Ars_Sigla FROM Areas WHERE Ars_Codigo = '#form.cbareacs#'
			</cfquery>
			<cfset aux_posarea = #form.cbareacs#>
			<cfset aux_posnomearea = #rsAreacs.Ars_Sigla#>
		</cfif>
			
		<!--- Tratamento quanto a data de previsão da solução --->
		<cfif form.frmdtprev neq "">
		   <cfset auxano = right(form.frmdtprev,4)>
		   <cfset auxmes = mid(form.frmdtprev,4,2)>
		   <cfset auxdia = left(form.frmdtprev,2)>
		   <cfset dtnovoprazo = CreateDate(auxano,auxmes,auxdia)>
			<cfoutput>
			<cfset nCont = 1>
			<cfloop condition="nCont lte 1">
				<cfset nCont = nCont + 1>
				<cfset vDiaSem = DayOfWeek(dtnovoprazo)>
				<cfif vDiaSem neq 1 and vDiaSem neq 7>
					<!--- verificar se Feriado Nacional --->
					<cfquery name="rsFeriado" datasource="#dsn_inspecao#">
						 SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dtnovoprazo#
					</cfquery>
					<cfif rsFeriado.recordcount gt 0>
					   <cfset nCont = nCont - 1>
					   <cfset dtnovoprazo = DateAdd( "d", 1, dtnovoprazo)>
					</cfif>
				</cfif>
				<!--- Verifica se final de semana  --->
				<cfif vDiaSem eq 1 or vDiaSem eq 7>
					<cfset nCont = nCont - 1>
					<cfset dtnovoprazo = DateAdd( "d", 1, dtnovoprazo)>
				</cfif>	
			</cfloop>	
			</cfoutput>
				<!--- fim loop --->
			<cfset dtprevsol = CreateDate(year(now()),month(now()),day(now()))>
			<cfset dtprevsol = "Data de Previsão da Solução: " & #DateFormat(dtnovoprazo,"dd/mm/yyyy")#>
		<cfelse>
			<cfset dtprevsol = "">
			<cfset dtnovoprazo = CreateDate(year(now()),month(now()),day(now()))>
		</cfif>   
		<!--- ++++++++++++++++++++++++++++++++++++++++++++++++++++ --->	   
		<!--- Tratamento quanto a Situação --->	   
		<cfif form.frmResp neq "">
			  <cfquery name="rsPonto" datasource="#dsn_inspecao#">
				 SELECT STO_Codigo, STO_Sigla, STO_Descricao FROM Situacao_Ponto WHERE STO_Codigo = #form.frmResp#
			  </cfquery>
			  <cfloop query="rsPonto">
				 <cfif form.frmResp eq rsPonto.STO_Codigo>
				   <cfset IDStatus = #form.frmResp#>
				   <cfset SglStatus = #rsPonto.STO_Sigla#>
				   <cfset DescStatus = #rsPonto.STO_Descricao#>
				 </cfif>
			  </cfloop>   
			  <cfset Situacao = "Situação: " & #DescStatus#>   
		<cfelse>
			   <cfset IDStatus = "">
			   <cfset SglStatus = "">
			   <cfset DescStatus = "">
			   <cfset Situacao = ""> 
		</cfif>
		<!--- Tratamento mensagem da Pos_Parecer e And_Parecer --->
		<cfset Encaminhamento = 'Opinião do Controle Interno'>
		<cfif form.frmmensagem neq "">
			<cfset sinformes = #form.frmmensagem#>
		<cfelse>
			<cfset sinformes = "">
		</cfif>
		
		<!--- OBTER O PARECER --->
		<cfquery name="rsPar" datasource="#dsn_inspecao#">
          SELECT Pos_Area, Pos_Nomearea, Pos_Parecer, Pos_Situacao_Resp FROM ParecerUnidade WHERE (Pos_Unidade = '#dbunid#') AND (Pos_Inspecao = '#dbinsp#') AND (Pos_NumGrupo = #dbgrupo#) AND (Pos_NumItem = #dbitem#)
       </cfquery>


		<!---  --->
		<!--- ++++++++++++++++++++++++++++++++++++++++++++++++++++ --->
		  <cfif rsPar.recordcount gt 0>   
	 	   <!--- INICIO temporário para atualizar os pontos LEVES --->
	<!---	   <cfset aux_posarea = #rsPar.Pos_Area#>
		   <cfset aux_posnomearea = #rsPar.Pos_Nomearea#>
		   #rsPar.Pos_Area# - #rsPar.Pos_Nomearea#
		   <CFSET GIL = GIL> --->
		   <!--- FINAL temporário para atualizar os pontos LEVES --->		  
		     <!--- Atualizar andamento --->
			 <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & "-" & TimeFormat(Now(),'HH:MM') & ">" & Trim(Encaminhamento) & CHR(13) & CHR(13) & "À(O) " & #trim(aux_posnomearea)# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & #Situacao# & CHR(13) & CHR(13) & #dtprevsol# & CHR(13) & CHR(13) & "Responsável: COORD VERIF CONTR UNID OP/GCOP" & CHR(13) & CHR(13) & "--------------------------------------------------------------------------------------------------------------">
			 <cfquery datasource="#dsn_inspecao#">
			   insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Area) values ('#dbinsp#', '#dbunid#', #dbgrupo#, #dbitem#, convert(char, getdate(), 102), 'Rotina_em_Lote', #IDStatus#, left(convert(char, getdate(), 114),10), '#and_obs#', '#aux_posarea#')
			 </cfquery>  
		     <!--- Atualizar ParecerUnidade --->			   
			  <cfset pos_obs = CHR(13) & #rsPar.Pos_Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & Trim(Encaminhamento) & CHR(13) & CHR(13) & 'À(O) ' & #trim(aux_posnomearea)# & CHR(13) & CHR(13) & #sinformes# & CHR(13) & CHR(13) & #Situacao# & CHR(13) & CHR(13) & #dtprevsol# & CHR(13) & CHR(13) & 'Responsável: COORD VERIF CONTR UNID OP/GCOP' & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
			   <cfquery datasource="#dsn_inspecao#">
			   UPDATE ParecerUnidade SET Pos_Situacao_Resp = #IDStatus# 
			   , Pos_Situacao = '#SglStatus#'
			   , Pos_DtPosic = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))# 
			   <cfif form.frmdtprev neq "">
			   , Pos_DtPrev_Solucao = #dtnovoprazo#
			   </cfif>
			   , Pos_Area = '#aux_posarea#'
			   , Pos_Nomearea = '#aux_posnomearea#'
			   <cfif form.frmmensagem neq "">
			   , Pos_Parecer = '#pos_obs#' 
			   </cfif>
			   , pos_username = '#CGI.REMOTE_USER#'
			   , Pos_DtUltAtu = CONVERT(char, GETDATE(), 120) 
			   , Pos_Sit_Resp_Antes = #rsPar.Pos_Situacao_Resp#
			   WHERE (Pos_Unidade = '#dbunid#') AND (Pos_Inspecao = '#dbinsp#') AND (Pos_NumGrupo = #dbgrupo#) AND (Pos_NumItem = #dbitem#)
			 </cfquery> 
    
			 <cfset auxdadosproc = #auxdadosproc# & #dbunid# & "  " & #dbinsp# & "     " & #dbgrupo# & #RepeatString(" ", 8 - len(dbgrupo))# & #dbitem# & CHR(13)>
			 <cfset ArrayAppend(arqlotesai, "#dbunid##dbinsp#G#dbgrupo#I#dbitem#")>	
			 <cfset qtdproc = qtdproc + 1>
		  <cfelse>
		     <cfset auxdadosnproc = #auxdadosnproc# & #dbunid# & "  " & #dbinsp# & "     " & #dbgrupo# & #RepeatString(" ", 8 - len(dbgrupo))# & #dbitem# & CHR(13)>
			 <cfset qtdnproc = qtdnproc + 1>
		  </cfif>  
</cfloop>
 </cfif>
    <!--- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ --->

  <cfif isDefined("Form.acao") And (Form.acao is 'Salvar')>
  	 <!--- Classificar o array de saida --->
     <cfset myList = ArrayToList(arqlotesai, ",")>
     <cfset isSuccessful = ArraySort(arqlotesai, "textnocase")> 
	   <!---  Dados para envio de e-mail por se : <cfdump var="#arqlotesai#"> --->
	   <!--- ****************************** --->
	   <!--- Tratamento salva dos anexos --->	
	   <cfif form.existeanexo eq "S">
			<cfset sinic = 0>
			<cfset sfim = 0>
			<cfset stam = 0>
			<cfset nCont = 1>
			<cfset auxse = left(arqlotesai[1],2)>
			<cfset auxtotreg = ArrayLen(arqlotesai)>
		    
			<cfloop condition="#nCont# lte #auxtotreg#">
			  <cfset dbunid = #left(arqlotesai[nCont],8)#>
			  <cfset dbinsp = #mid(arqlotesai[nCont],9,10)#>
			  <cfset sinic = findOneOf('G', arqlotesai[nCont])>
			  <cfset sinic = sinic + 1>
			  <cfset sfim = findOneOf('I', arqlotesai[nCont], sinic)>
			  <cfset stam = sfim - sinic>
			  <cfset dbgrupo = trim(mid(arqlotesai[nCont],sinic,stam))>
			  <cfset sinic = sfim + 1>
			  <cfset dbitem = trim(mid(arqlotesai[nCont],sinic,len(arqlotesai[nCont])))>
			  <cfset sinic = 0>
			  <cfset sfim = 0>
			   
		  	   <cfdirectory name="qList" filter="*.pdf" sort="name desc" directory="#GetDirectoryFromPath(gettemplatepath())#Dados\Proc_Lote\">
				   <cfloop query= "qList">
						<cfset data = DateFormat(now(),'DD-MM-YYYY') & '-' & TimeFormat(Now(),'HH') & 'h' & TimeFormat(Now(),'MM') & 'min' & TimeFormat(Now(),'l') & 'l'>
						<cfset destino = #diretorio_anexos# & '\' & #dbinsp# & '_' & #data# & '_' & right(CGI.REMOTE_USER,8) & '_' & #dbgrupo# & '_' & #dbitem# & '.pdf'>
						<cfquery datasource="#dsn_inspecao#" name="qVerifica">
						 INSERT INTO Anexos(Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Caminho) VALUES ('#dbinsp#','#dbunid#',#dbgrupo#,#dbitem#,'#destino#')
						</cfquery>  
						<cffile action="copy" source="#GetDirectoryFromPath(gettemplatepath())#Dados\Proc_Lote\#name#"	destination="#destino#">
				 </cfloop> 
			    <cfset nCont = (nCont + 1)>
     	  </cfloop>
	  </cfif> 
	<!--- Fim anexos --->	
	   <!--- ****************************** --->
	   <!--- Tratamento e-mail agrupado --->
	  <cfif (form.frmemail neq "")>   
		<cfset sinic = 0>
		<cfset sfim = 0>
		<cfset stam = 0>
		<cfset nCont = 1>
		<cfset auxse = left(arqlotesai[1],2)>
		<cfset auxtotreg = ArrayLen(arqlotesai)>
		<cfset auxindini = 1>
		<cfset auxindfim = 0>
		<cfset sdestina = "">
		<!--- qtd de pontos: #auxtotreg#<br>  --->
		<!--- <cfset gil = gil> --->
		 <cfloop condition="#nCont# lte #auxtotreg#">
		 	  <cfset dbunid = #left(arqlotesai[nCont],8)#>
			  <cfset dbinsp = #mid(arqlotesai[nCont],9,10)#>
			  <cfset sinic = findOneOf('G', arqlotesai[nCont])>
			  <cfset sinic = sinic + 1>
			  <cfset sfim = findOneOf('I', arqlotesai[nCont], sinic)>
			  <cfset stam = sfim - sinic>
			  <cfset dbgrupo = trim(mid(arqlotesai[nCont],sinic,stam))>
			  <cfset sinic = sfim + 1>
			  <cfset dbitem = trim(mid(arqlotesai[nCont],sinic,len(arqlotesai[nCont])))>
			  <cfset sinic = 0>
			  <cfset sfim = 0> 

			  <cfif (auxse neq left(arqlotesai[nCont],2))>
			       <cfif auxindfim lt auxtotreg>
				   		<cfset auxindfim = (nCont - 1)> 
				   </cfif>
				   
					<!--- <cfif form.frmResp eq 21> --->
						 <!--- email da SCOI agrupado por SE de cada SCOI --->
						 <cfquery name="rsSCOI" datasource="#dsn_inspecao#">
							 SELECT Ars_Email
							 FROM Areas 
							 WHERE (Ars_Sigla Like '%DCINT/GCOP/CCOP/SCOI%' OR Ars_Sigla Like '%DCINT/GCOP/SGCIN/SCOI') AND (Ars_Status = 'A') AND (Left([Ars_Codigo],2) = '#left(arqlotesai[auxindini],2)#')
						 </cfquery>
						 <cfset sdestina = rsSCOI.Ars_Email>
					<!--- </cfif>  ---> 
					 <!---  --->
					<cfif form.frmResp eq 9>
						 <!--- email da CS agrupado por SE --->
						 <cfquery name="rsCS" datasource="#dsn_inspecao#">
							 SELECT Ars_Email, Ars_Sigla
							 FROM Areas WHERE Ars_Codigo = '#Form.cbareacs#'
						</cfquery>
						 <cfset sdestina = sdestina & ';' & rsCS.Ars_Email>
					</cfif>  
					 <!---  --->
					<cfif findoneof("@", trim(sdestina)) eq 0>
						<!--- <cfset sdestina = "adrianosoares@correios.com.br"> --->
					</cfif> 
					<!---  --->
					<!---  <cfset sdestina = "gilvanm@correios.com.br"> --->
				    <cfset auxse = left(arqlotesai[nCont],2)>
				    <cfmail from="SNCI@correios.com.br" to="#sdestina#" subject="Ajuste por Lote" type="HTML">  
						  Mensagem automática. Não precisa responder!<br><br> 
					 <strong>
					  #form.frmemail#<br><br>
						<table>
							<tr>
							<td><strong>Unidade</strong></td>
							<td><strong>Descricao</strong></td>
							<td><strong>Inspeção</strong></td>
							<td><strong>Grupo</strong></td>
							<td><strong>Item</strong></td>
							</tr>
							<tr>
							<td>----------------</td>
							<td>-----------------------------------------</td>
							<td>----------------</td>
							<td>--------</td>
							<td>------</td>
							</tr>  --->
	
							<cfloop from="#auxindini#" to="#auxindfim#" index="x">
							  <cfset unidagrupa = #left(arqlotesai[x],8)#>
							  <cfset inspagrupa = #mid(arqlotesai[x],9,10)#>
							  <cfset sinic = findOneOf('G', arqlotesai[x])>
							  <cfset sinic = sinic + 1>
							  <cfset sfim = findOneOf('I', arqlotesai[x], sinic)>
							  <cfset stam = sfim - sinic>
							  <cfset grupoagrupa = trim(mid(arqlotesai[x],sinic,stam))>
							  <cfset sinic = sfim + 1>
							  <cfset itemagrupa = trim(mid(arqlotesai[x],sinic,len(arqlotesai[x])))>
							  <cfset sinic = 0>
							  <cfset sfim = 0>
							 <!--- Descrição da Unidade --->
							 <cfquery name="rsDescUnid" datasource="#dsn_inspecao#">
								 SELECT Und_Descricao 
								 FROM Unidades 
								 WHERE Und_Codigo = '#unidagrupa#'
							 </cfquery>
								<tr>
								<td><strong>#unidagrupa#</strong></td>
								<td><strong>#rsDescUnid.Und_Descricao#</strong></td>
								<td align="center"><strong>#inspagrupa#</strong></td>
								<td align="center"><strong>#grupoagrupa#</strong></td>
								<td align="center"><strong>#itemagrupa#</strong></td>
								</tr>
						   </cfloop> 
					</table>
					</strong>
				  </cfmail>	   
				<cfset auxse = left(arqlotesai[nCont],2)>
				<cfset auxindini = nCont>
				 <cfset nCont = auxindfim>
			</cfif>  
  		    <cfset nCont = (nCont + 1)>
       </cfloop>
	   <!--- Inicio da Saida  --->
	    <cfset sinic = 0>
		<cfset sfim = 0>
		<cfset stam = 0>
		<cfset nCont = auxindfim + 1> 
		<cfset auxse = "fim">
		<cfset auxtotreg = ArrayLen(arqlotesai)>
		<cfset auxindini = nCont>
		<cfset auxindfim = auxtotreg>
		<!--- qtd de pontos: #auxtotreg#<br>  --->
		<!--- <cfset gil = gil> --->
		 <cfloop condition="#nCont# lte #auxtotreg#">
		 	  <cfset dbunid = #left(arqlotesai[nCont],8)#>
			  <cfset dbinsp = #mid(arqlotesai[nCont],9,10)#>
			  <cfset sinic = findOneOf('G', arqlotesai[nCont])>
			  <cfset sinic = sinic + 1>
			  <cfset sfim = findOneOf('I', arqlotesai[nCont], sinic)>
			  <cfset stam = sfim - sinic>
			  <cfset dbgrupo = trim(mid(arqlotesai[nCont],sinic,stam))>
			  <cfset sinic = sfim + 1>
			  <cfset dbitem = trim(mid(arqlotesai[nCont],sinic,len(arqlotesai[nCont])))>
			  <cfset sinic = 0>
			  <cfset sfim = 0> 

			  <cfif (auxse neq left(arqlotesai[nCont],2))>
			       <cfif auxindfim lt auxtotreg>
				   		<cfset auxindfim = (nCont - 1)> 
				   </cfif>
<!--- 					ause: #auxse#   auxindini: #auxindini#   auxindfim: #auxindfim# <br>
					ncont: #nCont#  ---- unidade_se : #dbunid# inspe: #dbinsp#   grupo: #dbgrupo#   Item : #dbitem#<br> --->
					
					<cfif form.frmResp eq 21>
						 <!--- email da SCOI agrupado por SE de cada SCOI --->
						 <cfquery name="rsSCOI" datasource="#dsn_inspecao#">
							 SELECT Ars_Email
							 FROM Areas 
							 WHERE (Ars_Sigla Like '%DCINT/GCOP/CCOP/SCOI%' OR Ars_Sigla Like '%DCINT/GCOP/SGCIN/SCOI') AND (Ars_Status = 'A') AND (Left([Ars_Codigo],2) = '#left(arqlotesai[auxindini],2)#')
						 </cfquery>
						 <cfset sdestina = rsSCOI.Ars_Email>
					</cfif>  
					 <!---  --->
					<cfif form.frmResp eq 9>
						 <!--- email da CS agrupado por SE --->
						 <cfquery name="rsCS" datasource="#dsn_inspecao#">
							 SELECT Ars_Email, Ars_Sigla
							 FROM Areas WHERE Ars_Codigo = '#Form.cbareacs#'
						</cfquery>
						 <cfset sdestina = rsCS.Ars_Email>
					</cfif>  
					<cfif form.frmResp eq 10>
						 <!--- email da CS agrupado por SE --->
						 <cfquery name="rsUnid" datasource="#dsn_inspecao#">
							 SELECT Und_Email 
							 FROM Unidades
							 WHERE Und_Codigo = '#dbunid#'
						</cfquery>
						<cfset sdestina = rsUnid.Und_Email>
					</cfif>
					 <!---  --->
					<cfif findoneof("@", trim(#sdestina#)) eq 0>
						<!--- <cfset sdestina = "adrianosoares@correios.com.br"> --->
					</cfif> 
					<!---  --->
					 <!--- <cfset sdestina = "gilvanm@correios.com.br">  --->
				    <cfset auxse = left(arqlotesai[nCont],2)>
				    <cfmail from="SNCI@correios.com.br" to="#sdestina#" subject="Ajuste por Lote" type="HTML"> 
						 Mensagem automática. Não precisa responder!<br><br>
					 <strong>
					 #form.frmemail#<br><br> 
						<table>
							<tr>
							<td><strong>Unidade</strong></td>
							<td><strong>Descricao</strong></td>
							<td><strong>Inspeção</strong></td>
							<td><strong>Grupo</strong></td>
							<td><strong>Item</strong></td>
							</tr>
							<tr>
							<td>----------------</td>
							<td>-----------------------------------------</td>
							<td>----------------</td>
							<td>--------</td>
							<td>------</td>
							</tr>
							<cfloop from="#auxindini#" to="#auxindfim#" index="x">
							  <cfset unidagrupa = #left(arqlotesai[x],8)#>
							  <cfset inspagrupa = #mid(arqlotesai[x],9,10)#>
							  <cfset sinic = findOneOf('G', arqlotesai[x])>
							  <cfset sinic = sinic + 1>
							  <cfset sfim = findOneOf('I', arqlotesai[x], sinic)>
							  <cfset stam = sfim - sinic>
							  <cfset grupoagrupa = trim(mid(arqlotesai[x],sinic,stam))>
							  <cfset sinic = sfim + 1>
							  <cfset itemagrupa = trim(mid(arqlotesai[x],sinic,len(arqlotesai[x])))>
							  <cfset sinic = 0>
							  <cfset sfim = 0>
							 <!--- Descrição da Unidade --->
							 <cfquery name="rsDescUnid" datasource="#dsn_inspecao#">
								 SELECT Und_Descricao 
								 FROM Unidades 
								 WHERE Und_Codigo = '#unidagrupa#'
							 </cfquery>
								<tr>
								<td><strong>#unidagrupa#</strong></td>
								<td><strong>#rsDescUnid.Und_Descricao#</strong></td>
								<td align="center"><strong>#inspagrupa#</strong></td>
								<td align="center"><strong>#grupoagrupa#</strong></td>
								<td align="center"><strong>#itemagrupa#</strong></td>
								</tr>
						   </cfloop> 
					</table>
					</strong>
				</cfmail>	
				<cfset auxse = left(arqlotesai[nCont],2)>
				<cfset auxindini = nCont>
				 <cfset nCont = auxindfim>
			</cfif>  
  		    <cfset nCont = (nCont + 1)>
       </cfloop>
	   <!---  --->
      </cfif>
      <!--- fim tratamento e-mail agrupado --->	   
       <!--- ****************************** --->
<!--- 	loteagrupa<br><cfdump var="#arqloteagrupa#"> --->
		<table width="866" border="0">
			<tr class="exibir">
				<td colspan="2"><strong class="titulos">Total de ( #qtdproc# ) registros processados.</strong></td>
		  </tr>
			  <tr class="exibir">
				<td colspan="2"><textarea name="textareas" cols="45" rows="6">#auxdadosproc#</textarea></td>
		  </tr>
			  <tr class="exibir">
				<td colspan="2">&nbsp;</td>
		  </tr>

		  <tr class="exibir">
				<td colspan="2"><strong class="titulos">Total de ( #qtdnproc# ) registros Rejeitados.</strong></td>
		  </tr>
		  </tr>
			  <tr class="exibir">
				<td colspan="2"><textarea name="textarean" cols="45" rows="6">#auxdadosnproc#</textarea></td>
		  </tr>
			  <tr class="exibir">
				<td colspan="2">&nbsp;</td>
		  </tr>
			  <tr class="exibir">
				<td colspan="2"><div align="left"><strong>Fim Processamento em Lote.</strong></div></td>
		  </tr>
		  </table>
		  <cfdirectory name="qList" filter="*.*" sort="name desc" directory="#GetDirectoryFromPath(gettemplatepath())#Dados\Proc_Lote\">
			  <cfloop query= "qList">
				  <cffile action="delete" file="#GetDirectoryFromPath(gettemplatepath())#Dados\Proc_Lote\#name#">
			  </cfloop>
		  <cfabort>
</cfif>	
<!--- inicio do corpo --->
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script type="text/javascript">
<cfinclude template="mm_menu.js">

//===================
function avisonci(){
//alert(document.form1.nci.value);
//alert(document.form1.frmnumseinci.value);
var x=document.form1.nci.value;
 var k=document.form1.frmnumseinci.value;
	if (x == 'Sim' && k.length == 20)
    {
	document.form1.nseincirel.value = k;
	alert('Gestor(a), Para essa informação é necessário registrar um anexo');
	}
}
//===================
function hanci(){
// alert(document.form1.nseincirel.value);
 var x=document.form1.nci.value;
 var k=document.form1.nseincirel.value;
 window.ncisei.style.visibility = 'hidden';
  if (x=='Sim'){
    window.ncisei.style.visibility = 'visible';
    document.form1.frmnumseinci.value = document.form1.nseincirel.value;
    if (k.length != 20)
    {
	 // document.form1.frmnumseinci.disabled=true;
	}
  }
}
//=================
function proc_disc(){
 var x=document.form1.abertura.value;
 window.dproc.style.visibility = 'hidden';
  if (x=='Sim'){
    window.dproc.style.visibility = 'visible';
  }
}
//=================
function exibe(a){
 // alert('exibe: ' + a);
  exibirArea(a);
  exibirAreaCS(a);
  dtprazo(a);
//  if (a==10) {document.getElementById("frmdtprev").readOnly = true; //document.form1.frmdtprev.disabled=true;}
}
var ind
function exibirArea(ind){
//alert('exibirArea: ' + ind);
  document.form1.cbarea.disabled=true;
  document.form1.cbarea.selectedIndex = 0;
  if (ind==21)
  {
   // buscaopt('DCINT/GCOP/SGCIN/SCIA')
  } else {
	document.form1.cbarea.selectedIndex = 0;
  }
}
//====================
var idx
function exibirAreaCS(idx){
  document.form1.cbareacs.selectedIndex = 0;
  document.form1.cbareacs.disabled=true; 
  
  if (idx==9 || idx==29){
      document.form1.cbareacs.disabled=false;
	  document.form1.cbarea.selectedIndex = 0;
	}
}
//==========================
// travar o combobox(cbArea) em um determinado valor
function buscaopt(a) {
//alert(a);
   var opt_sn = 'N';
   var comboitem = document.getElementById("cbArea");
   for (i = 1; i < comboitem.length; i++) {
       // comparando o valor do label
       if (comboitem.options[i].text.substring(comboitem.options[i].text.indexOf("/") + 1,comboitem.options[i].text.length) ==  a)
	   {
       //     alert(i);
		  opt_sn = 'S'
          comboitem.selectedIndex = i;
          comboitem.disabled=true;
          i = comboitem.length;
         }
    }
	if (opt_sn == "N")
	{
       //    alert(i);
       comboitem.selectedIndex = 0;
       comboitem.disabled=false;
    }
}
//==========================
function dtprazo(k){
//alert(k);
   document.getElementById("frmdtprev").readOnly = true;
   document.form1.frmdtprev.value = document.form1.dthojeddmmyyy.value;
	 //alert('dtprazo: ' + k);
	 if (k == 15)
	 {
	//   document.getElementById("frmdtprev").readOnly = false;
	   document.form1.frmdtprev.value = document.form1.dtdezdiasfut.value;
	 }
 
}
//==========================
function validafrm()
{
	 if (document.form1.acao.value == 'Anexar')
	 {
	     var auxpdf = document.form1.arquivopdf.value;
	     auxpdf = auxpdf.toUpperCase();
		if (auxpdf.indexOf(".PDF") == -1) 
			{
			  alert("Formato difere do (PDF)");
			  return false;
		   }
	}
  
  if (document.form1.acao.value == 'Salvar'){
	   //********************
	   var anexoSN = 'N';   
	   if (document.form1.existeanexo.value == "N")
		{
		   var auxcam = "\n\nNão existe arquivo Anexo para esse Lote.\n\n Confirma em continuar mesmo assim?";
		 if (confirm ('            Atenção! ' + auxcam))
			{
			anexoSN = 'S';
			}
		else
		   {
		   return false;
		   }
		}
     //*******************
	   var emailSN = 'N';   
	   var auxemail = document.form1.frmemail.value;
	   if (auxemail == "")
		{
		   var auxcam = "\n\nMensagem para o corpo do E-mail ao CCOP/SE, está vazio!\n\n Confirma em continuar mesmo assim?";
	
		 if (confirm ('            Atenção! ' + auxcam))
			{
			emailSN = 'S';
			}
		else
		   {
		   return false;
		   }
		}		
	   
       if (auxemail == "" && emailSN == 'N')
	   {
	     alert("Caro Usuário, Mensagem para o corpo do E-mail ao CCOP/SE, está vazio!");
	      return false;
	   }
	   //*******************************	 
	   var msgSN = 'N';   
	   var auxmenhist = document.form1.frmmensagem.value;
	   if (auxmenhist == "")
		{
		    var auxcam = "\n\nMensagem para registro no histórico do ponto, está vazio!\n\n Confirma em continuar mesmo assim?";
		 if (confirm ('            Atenção! ' + auxcam))
			{
			msgSN = 'S';
			}
		else
		   {
		   return false;
		   }
		}		

       if (auxmenhist == "" && msgSN == 'N')
	   {
	   alert("Caro Usuário, Mensagem para registro no histórico do ponto,  está vazio!");
	   return false;
	   }
     //**********************************
       var sitSN = 'N';   
	/*   if (document.form1.frmResp.value == "")
		{
		   var auxcam = "\n\nFoi identificado a falta da Situação para esse Lote.\n\n Confirma em continuar a execução da rotina?";
		 if (confirm ('            Atenção! ' + auxcam))
			{
			sitSN = 'S';
			}
		else
		   {
		   return false;
		   }
		}		
*/		
	   var auxsit = document.form1.frmResp.value;
	   if (auxsit == '' && sitSN == "N")
		  {
		   alert('Caro Usuário, Selecione uma Situação!');
		   return false;
		  }

	   if ((auxsit == 9 || auxsit == 29) && (document.form1.cbareacs.value == ''))
		  {
		   alert('Caro Usuário, Selecione a Área(CS)!');
		   return false;
		  }		
		//******************************************
		 var dtprevdig = document.form1.frmdtprev.value;
		 var dtprevSN = 'N';
/*		 if (dtprevdig == "")
		{
		   var auxcam = "\n\nFoi identificado a Falta da Data de Previsão da Solução.\n\n Confirma em continuar a execução da rotina?";
	
		 if (confirm ('            Atenção! ' + auxcam))
			{
			dtprevSN = 'S';
			}
		else
		   {
		   return false;
		   }
		}
*/	
		if (dtprevdig.length != 10 && dtprevSN == 'N')
		{
			alert("Preencher campo: Data da Previsão da Solução ex. DD/MM/AAAA");
			return false;
		}
		
        var dt_hoje_yyyymmdd = document.form1.dthojeyyyymmdd.value;
		 //alert(a);
		 var vDia = dtprevdig.substr(0,2);
		 var vMes = dtprevdig.substr(3,2);
		 var vAno = dtprevdig.substr(6,10);
		 var dtprevdig_yyyymmdd = vAno + vMes + vDia

		if (dt_hoje_yyyymmdd > dtprevdig_yyyymmdd && dtprevSN == 'N')
		{
		  alert('Data de Previsão da Solução deve ser superior a data corrente(do dia)!')
		  return false;
		}		
		//********************************
	  if (confirm ("Confirma Atualizar Pontos por Lote, Agora?"))
	   {
	    //document.form1.frmdtprev.disabled=false;
		document.getElementById("frmdtprev").readOnly = true;
		return true;
		}
	else
	   {
	   return false;
	   }
  }
//********************************
}
</script>

</head>
<!--- <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<div id="Layer1" style="position:absolute; left:11px; top:6px; width:7px; height:6px; z-index:1"></div> --->

<cfinclude template="cabecalho.cfm">
  <cfquery name="rsPonto" datasource="#dsn_inspecao#">
	SELECT STO_Codigo, STO_Sigla, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' and STO_Codigo in (3,9,10,13,15,21,28,29) order by STO_Descricao
  </cfquery>
  <cfquery name="qArea" datasource="#dsn_inspecao#">
 SELECT DISTINCT Ars_Codigo, Ars_Sigla
 FROM Areas WHERE Ars_Status = 'A'
 ORDER BY Ars_Sigla
</cfquery>

<cfquery name="qAreaCS" datasource="#dsn_inspecao#">
 SELECT DISTINCT Ars_Codigo, Ars_Sigla
 FROM Areas WHERE Ars_Status = 'A' AND (Left(Ars_Codigo,2) = '01')
 ORDER BY Ars_Sigla
</cfquery>
<body onLoad="exibe(document.form1.frmResp.value)">
 <form name="form1" method="post" onSubmit="return validafrm()" enctype="multipart/form-data" action="Itens_ajustaremlote1.cfm">
      <table width="95%" border="0">

  <tr>
    <td colspan="3" class="exibir"><table width="866" border="0">
	<tr class="exibir">
        <td colspan="2"><strong class="titulos"> Extra&iacute;dos do CSV - Total de #qtdcsv# registros. </strong></td>
        </tr>
 <cfset myList = ArrayToList(arqloteent, ",")>
  <cfset isSuccessful = ArraySort(arqloteent, "textnocase")> 
<!---   <cfdump var="#arqloteent#"> --->
<cfset sinic = 0>
<cfset sfim = 0>
<cfset stam = 0>
  <cfloop from="1" to="#ArrayLen(arqloteent)#" index="i">
          <cfset dbunid = #left(arqloteent[i],8)#>
		  <cfset dbinsp = #mid(arqloteent[i],9,10)#>
		  <cfset sinic = findOneOf('G', arqloteent[i])>
		  <cfset sinic = sinic + 1>
		  <cfset sfim = findOneOf('I', arqloteent[i], sinic)>
		  <cfset stam = sfim - sinic>
		  <cfset dbgrupo = trim(mid(arqloteent[i],sinic,stam))>
		  <cfset sinic = sfim + 1>
		  <!--- <cfset sinic = findOneOf(';', arqloteent[i], sinic) + 1> --->
		  <cfset dbitem = trim(mid(arqloteent[i],sinic,len(arqloteent[i])))>
		  <cfset sinic = 0>
		 <cfset sfim = 0>
<!--- 		 #dbunid#   #dbinsp#   #dbgrupo#   #dbitem#<br> --->
         <cfset auxdados = #auxdados# & #dbunid# & "  " & #dbinsp# & "     " & #dbgrupo# & #RepeatString(" ", 8 - len(dbgrupo))# & #dbitem# & CHR(13)>
   </cfloop> 

       <tr class="exibir">
        <td colspan="2"><textarea name="textarea" cols="45" rows="6">#auxdados#</textarea></td>
        </tr> 

      <tr class="exibir">
        <td colspan="2">&nbsp;</td>
        </tr>
    </table></td>
    </tr>

	<tr>
	  <td colspan="3" class="exibir"><div align="center"><strong>Mensagem para o corpo do E-mail ao CCOP/SE</strong></div></td>
	  </tr>
	<tr>
	  <td colspan="3" class="exibir"><textarea name="frmemail" cols="140" rows="2" id="frmemail"></textarea></td>
	  </tr>
	<tr>
	  <td colspan="3" class="exibir"><div align="center"><strong> Mensagem para registro no hist&oacute;rico do ponto</strong></div></td>
	  </tr>
	<tr>
    <td colspan="3" class="exibir"><textarea name="frmmensagem" cols="140" rows="3" id="frmmensagem"></textarea></td>
    </tr>
	<tr>
	  <td colspan="6" class="exibir"><table width="872" border="0">
        <tr>
          <td width="70"><span class="form"><strong>Anexos</strong></span></td>
          <td width="792">&nbsp;</td>
        </tr>
      </table></td>
	  </tr>
	<tr>
	  <td colspan="6" class="exibir">
	  <table width="870" border="0">
	  <cfdirectory name="qList" filter="*.pdf" sort="name desc" directory="#GetDirectoryFromPath(gettemplatepath())#Dados\Proc_Lote\">
	 <cfset existeanexoSN = "N">
	  <cfloop query= "qList">
	    <cfset existeanexoSN = "S">
	        <tr>
			  <td width="770" height="75%" bgcolor="##6699FF"><a href="Dados\Proc_Lote\#name#" target="_blank" class="titulos">#name#</a></td>
		      <td width="90"><div align="center">
		        <input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Excluir';document.form1.vCodigo.value=this.codigo" value="Excluir Este" codigo="#name#">
		        </div></td>
	        </tr> 
        <tr>
      </cfloop>
	 </table></td>
	  </tr>
      
	<tr>
	  <td colspan="6" class="exibir"><table width="867" border="0">
        <tr>
          <td width="79"><strong class="exibir">Arquivos:</strong></td>
          <td width="687"><input name="arquivopdf" class="botao" type="file" size="50"></td>
          <td width="87"><div align="center">
            <input name="Submit" type="Submit" class="botao" onClick="document.form1.acao.value='Anexar'" value="Anexar">
          </div></td>
        </tr>
      </table></td>
    </tr>
	<tr>
	  <td colspan="6" class="exibir">&nbsp;</td>
	  </tr>
	   <tr class="exibir">
        <td width="82"><strong>Situa&ccedil;&atilde;o:</strong></td>
        <td width="1156">
		<select name="frmResp" class="form" id="frmResp" onChange="exibe(this.value)">
          <option selected="selected" value="">---</option>
          <cfloop query="rsPonto">
            <option value="#STO_Codigo#">#trim(STO_Descricao)#</option>
          </cfloop>
        </select></td>
      </tr>
	  	<tr>
	  <td colspan="6" class="exibir">&nbsp;</td>
	  </tr>
	   <tr>
	     <td colspan="6" class="exibir"><table width="913" border="0">
           <tr>

	<td height="22" class="exibir"><strong>Selecione a &Aacute;rea: </strong>	  
	            <select name="cbarea" id="cbarea" class="form">
                  <option selected="selected" value="">---</option>
                  <cfloop query="qArea">
                    <option value="#Ars_Sigla#">#trim(Ars_Sigla)#</option>
                  </cfloop>
                  </select>
			  </td>
              <td class="exibir">
                <div align="left"><strong>Selecione a &Aacute;rea(CS): </strong>
				  <select name="cbareacs" id="cbareacs" class="form">
                  <option selected="selected" value="">---</option>
                  <cfloop query="qAreaCS">
                    <option value="#Ars_Codigo#">#trim(Ars_Sigla)#</option>
                  </cfloop>
                    </select>
              </div>                </td>
            </tr>
         </table></td>
        </tr>
			  	<tr>
	  <td colspan="6" class="exibir">&nbsp;</td>
	  </tr>
<!--- dez dias uteis futuro  --->	 
		<cfset dtposicfut = CreateDate(year(now()),month(now()),day(now()))> 
		<cfoutput>				
	<cfset nCont = 0>
	<cfloop condition="nCont lte 9">
		<cfset nCont = nCont + 1>
		<cfset dtposicfut = DateAdd( "d", 1, dtposicfut)>
		<cfset vDiaSem = DayOfWeek(dtposicfut)>
		<cfif vDiaSem neq 1 and vDiaSem neq 7>
			<!--- verificar se Feriado Nacional --->
			<cfquery name="rsFeriado" datasource="#dsn_inspecao#">
				 SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dtposicfut#
			</cfquery>
			<cfif rsFeriado.recordcount gt 0>
			   <cfset nCont = nCont - 1>
			</cfif>
		</cfif>
		<!--- Verifica se final de semana  --->
		<cfif vDiaSem eq 1 or vDiaSem eq 7>
			<cfset nCont = nCont - 1>
		</cfif>	
	</cfloop>
	</cfoutput>
	   <input name="dtdezdiasfut" type="hidden" id="dtdezdiasfut" value="<cfoutput>#DateFormat(dtposicfut,'DD/MM/YYYY')#</cfoutput>">
<!---  ---> 
	   <tr>
	 <td colspan="6" class="exibir"><table width="908" border="0">
      <tr>
        <td width="177" class="exibir"><strong>Dt. de Prev. da Solu&ccedil;&atilde;o:</strong></td>
        <td width="721"><input name="frmdtprev" id="frmdtprev" type="text" class="form" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="14" maxlength="10" value="#dateformat(now(),"dd/mm/yyyy")#"></td>
      </tr>
    </table>
	</td>
   </tr>
<!---   <tr>
    <td colspan="2" class="exibir">&nbsp;</td>
  </tr> --->
  <tr>
  <td colspan="3" class="exibir"><div align="center"></div>    
    <div align="center">
	  <input name="Submit" type="submit" class="botao" value="Confirmar a Atualização em Lote" onClick="document.form1.acao.value='Salvar'">
    </div></td>
    </tr>
</table>
      <input name="vCodigo" type="hidden" value="">
	  <input name="existeanexo" type="hidden" value="#existeanexoSN#">
      <input name="acao" id="acao" type="hidden" value="">
	  <input name="dthojeyyyymmdd" type="hidden" id="dthojeyyyymmdd" value="#DateFormat(now(),'YYYYMMDD')#">
	  <input name="dthojeyyyymmdd" type="hidden" id="dthojeddmmyyy" value="#DateFormat(now(),'dd/mm/yyyy')#">
	  <input name="anexoSN" type="hidden" id="anexoSN" value="S">
	  <input name="dtprevSolSN" type="hidden" id="dtprevSolSN" value="S">
	  <input name="mensagemSN" type="hidden" id="mensagemSN" value="S">
	  <input name="emailSN" type="hidden" id="emailSN" value="S">
	  <input name="situacaoSN" type="hidden" id="situacaoSN" value="S">
</form>
</body>
</html>
</cfoutput>