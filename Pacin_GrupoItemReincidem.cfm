<cfprocessingdirective pageEncoding ="utf-8"/>
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
   <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>  

<!--- gravaçao de dados --->

<cfif isDefined("Form.sacao") and #form.sacao# is 'inc'>
	<cfoutput>
		<cfif len(trim(form.frmgrpitmdb)) gt 0>
			<cfset auxreinc = #form.frmgrpitmdb# & "," & #form.frmgrpitmsel#>
		<cfelse>
			<cfset auxreinc = #form.frmgrpitmsel#>
		</cfif>
	    
		<cfquery datasource="#dsn_inspecao#">
			UPDATE  Itens_Verificacao set Itn_Reincidentes = '#auxreinc#'
			WHERE Itn_Ano='#form.frmano#' AND 
			Itn_NumGrupo=#form.auxgrp# AND
			Itn_NumItem=#form.auxitm# and 
			Itn_Modalidade = #form.frmmodal#
		</cfquery>
	</cfoutput> 
</cfif>
<!---  --->
<cfif isDefined("Form.sacao2") and #form.sacao2# is 'sus'>
	<cfoutput>
			<cfquery datasource="#dsn_inspecao#">
			UPDATE Itens_Verificacao set Itn_Reincidentes = '#form.frmgrpitmsel2#'
			WHERE Itn_Ano='#form.frmano#' AND 
			Itn_NumGrupo=#form.auxgrp# AND
			Itn_NumItem=#form.auxitm# and 
			Itn_Modalidade = #form.frmmodal#
		</cfquery>
	</cfoutput> 
	
</cfif>
<!--- fim gravaçao de dados  --->

<cfoutput>
	<cfset coluna = find("_", #form.frmgrpitm#)>
	<cfset auxgrp = left(#form.frmgrpitm#,(coluna - 1))>
	<cfset auxitm = mid(#form.frmgrpitm#,(coluna + 1),len(form.frmgrpitm))>
	<cfquery name="rsgrpitmtp" datasource="#dsn_inspecao#">
		SELECT Grp_Descricao, Itn_Descricao, TUN_Descricao, Itn_Reincidentes
		FROM Grupos_Verificacao 
		INNER JOIN Itens_Verificacao ON Grp_Codigo = Itn_NumGrupo AND Grp_Ano = Itn_Ano 
		INNER JOIN Tipo_Unidades ON Itn_TipoUnidade = TUN_Codigo
		WHERE Itn_Ano='#form.frmano#' AND 
		Itn_NumGrupo=#auxgrp# AND
		Itn_NumItem=#auxitm# and 
		Itn_Modalidade = #form.frmmodal#
	</cfquery>
	<cfset grpitmreg = 'Itn_NumGrupo is null'>
	<cfset grpitmliv = 'Itn_NumGrupo <> 0'>
    <cfset anoantes = (form.frmano) -1>
    <cfloop index="index" list="#rsgrpitmtp.Itn_Reincidentes#">
        <cfset grpitm = Replace(index,'_',',',"All")>
        <cfset grp = left(grpitm,find(",",grpitm)-1)>
        <cfset itm = mid(grpitm,(find(",",grpitm) + 1),len(grpitm))>
        <cfif grpitmreg eq 'Itn_NumGrupo is null'>
            <cfset grpitmreg = "Itn_NumGrupo = " & #grp# & " and Itn_NumItem = " & #itm#>
			<cfset grpitmliv = "(Itn_NumGrupo <> " & #grp# & " or Itn_NumItem <> " & #itm# & ")">
        <cfelse>
            <cfset grpitmreg = #grpitmreg# & " or Itn_NumGrupo = " & #grp# & " and Itn_NumItem = " & #itm#>
			<cfset grpitmliv = #grpitmliv# & " and (Itn_NumGrupo <> " & #grp# & " or Itn_NumItem <> " & #itm# & ")">
        </cfif>
        <cfset grp=''>
        <cfset itm=''>
    </cfloop> 

	<cfquery name="rsgritreg" datasource="#dsn_inspecao#">
		SELECT Grp_Descricao, Itn_Descricao, Itn_NumGrupo, Itn_NumItem, grp_ano 
		FROM Grupos_Verificacao INNER JOIN Itens_Verificacao ON Grp_Codigo = Itn_NumGrupo AND Grp_Ano = Itn_Ano 
		GROUP BY Grp_Descricao, Itn_Descricao, Itn_NumGrupo, Itn_NumItem, grp_ano 
		having Grp_Ano = #anoantes# and (#grpitmreg#)
		order by grp_ano, Itn_NumGrupo, Itn_NumItem
	</cfquery>

<!---
	<cfquery name="rsgritliv" datasource="#dsn_inspecao#">
		SELECT Grp_Descricao, Itn_Descricao, TUN_Descricao, Itn_NumGrupo, Itn_NumItem, itn_TipoUnidade, grp_ano
		FROM Grupos_Verificacao 
		INNER JOIN Itens_Verificacao ON Grp_Codigo = Itn_NumGrupo AND Grp_Ano = Itn_Ano 
		INNER JOIN Tipo_Unidades ON Itn_TipoUnidade = TUN_Codigo
		WHERE (Grp_Ano = #anoantes#) and #grpitmliv#
		order by grp_ano, Itn_NumGrupo, Itn_NumItem
	</cfquery>
--->	

	<cfquery name="rsgritliv" datasource="#dsn_inspecao#">
		SELECT Grp_Descricao, Itn_Descricao, Itn_NumGrupo, Itn_NumItem, grp_ano
		FROM (Grupos_Verificacao 
		INNER JOIN Itens_Verificacao ON (Grp_Codigo = Itn_NumGrupo) AND (Grp_Ano = Itn_Ano)) 
		GROUP BY grp_ano, Itn_Modalidade, Grp_Descricao, Itn_Descricao, Itn_NumGrupo, Itn_NumItem, Itn_Ano
		HAVING (((grp_ano)=#anoantes#) AND ((Itn_Modalidade)='0'))
		order by grp_ano, Itn_NumGrupo, Itn_NumItem
	</cfquery>
</cfoutput>

<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<title>Sistema Nacional de Controle Interno</title>
		<link href="../../estilo.css" rel="stylesheet" type="text/css">
		<link href="css.css" rel="stylesheet" type="text/css">
		<script type="text/javascript">
			// função que transmite as rotinas de alt, exc, etc...
			//=============================
			function avaliar(){
				document.form1.frmgrpitmsel.value = '';
				var totreg = document.form1.frmtotreg.value;
				document.form1.frmtotreg.value = 0;

				if (totreg == 1 && document.form1.cbgrpitm.checked == true) {
					document.form1.frmgrpitmsel.value = document.form1.frmgrpitmsel.value + '' + document.form1.cbgrpitm.value;
					document.form1.frmtotreg.value = 1;
				}

				for (x = 0 ; x <= totreg ; x++)	{
						if (document.form1.cbgrpitm[x].checked == true) {
							if (document.form1.frmgrpitmsel.value != '') {document.form1.frmgrpitmsel.value = document.form1.frmgrpitmsel.value + ',' + document.form1.cbgrpitm[x].value;}
							if (document.form1.frmgrpitmsel.value == '') {document.form1.frmgrpitmsel.value = document.form1.cbgrpitm[x].value;}
							document.form1.frmtotreg.value++;
						}
				}
			}
			//=============================
			function avaliar2(){
			//alert('linha53');
				document.form2.frmgrpitmsel2.value = '';
				var totreg = document.form2.frmtotreg2.value;
				document.form2.frmtotreg2.value = 0;

				if (totreg == 1 && document.form2.cbgrpitm2.checked == true) {
					document.form2.frmgrpitmsel2.value = document.form2.frmgrpitmsel2.value + '' + document.form2.cbgrpitm2.value;
					document.form2.frmtotreg2.value = 1;
				}

				for (x = 0 ; x <= totreg ; x++)	{
						if (document.form2.cbgrpitm2[x].checked == true) {
							if (document.form2.frmgrpitmsel2.value != '') {document.form2.frmgrpitmsel2.value = document.form2.frmgrpitmsel2.value + ',' + document.form2.cbgrpitm2[x].value;}
							if (document.form2.frmgrpitmsel2.value == '') {document.form2.frmgrpitmsel2.value = document.form2.cbgrpitm2[x].value;}
							document.form2.frmtotreg2.value++;
						}
				}
			}
			//=============================
			function todos(){
			//alert('linha 70');
				var totreg = document.form1.frmtotreg.value;
				
				if (totreg == 1 && document.form1.cbtodos.checked == false) {document.form1.cbgrpitm.checked = false; document.form1.confirma.disabled=true;} 
				if (totreg == 1 && document.form1.cbtodos.checked == true) {document.form1.cbgrpitm.checked = true; document.form1.confirma.disabled=false;} 
				
				for (x = 0 ; x <= totreg ; x++)	{
				if (document.form1.cbtodos.checked == true) {document.form1.cbgrpitm[x].checked = true; document.form1.confirma.disabled=false;}
				if (document.form1.cbtodos.checked == false) {document.form1.cbgrpitm[x].checked = false; document.form1.confirma.disabled=true;}
				}	
			}
			//=============================
			function todos2(){
			//alert('linha 89');
			//	var frm = document.forms[0];
				var totreg = document.form2.frmtotreg2.value;
			//	alert(document.form2.frmtotreg2.value);
				if (totreg == 1 && document.form2.cbtodos2.checked == false) {document.form2.cbgrpitm2.checked = false; document.form2.confirma2.disabled=false;} 
				if (totreg == 1 && document.form2.cbtodos2.checked == true) {document.form2.cbgrpitm2.checked = true; document.form2.confirma2.disabled=true;} 
				
				for (x = 0 ; x <= totreg ; x++)	{
				if (document.form2.cbtodos2.checked == true) {document.form2.cbgrpitm2[x].checked = true; document.form2.confirma2.disabled=true;}
				if (document.form2.cbtodos2.checked == false) {document.form2.cbgrpitm2[x].checked = false; document.form2.confirma2.disabled=false;}
				}
			
			}

			//=============================
			function habbtn(a){
			//alert(a);
				document.form1.confirma.disabled=true;
				var totreg = document.form1.frmtotreg.value;
				var auxtot = 0;
				
				if (totreg == 1 && document.form1.cbgrpitm.checked == true) {document.form1.confirma.disabled=false;}
				
				for (x = 0 ; x <= totreg ; x++)	
				{
				if (document.form1.cbgrpitm[x].checked == true) 
				{
				auxtot = 1;
				break
				}
				}
				
			if (auxtot > 0) {document.form1.confirma.disabled=false;}
			}

			//=============================
			function habbtn2(a){
			//alert(a);
				document.form2.confirma2.disabled=true;
				var totreg = document.form2.frmtotreg2.value;
			//alert(document.form2.frmtotreg2.value);
				var auxtot = 0;
				
				if (totreg == 1 && document.form2.cbgrpitm2.checked == false) {document.form2.confirma2.disabled=false;}
				
				for (x = 0 ; x <= totreg ; x++)	
				{
				if (document.form2.cbgrpitm2[x].checked == false) 
				{
				auxtot = 1;
				break
				}
				}
				
			if (auxtot > 0) {document.form2.confirma2.disabled=false;}
			}

		</script>
		<script language="JavaScript" src="../../mm_menu.js"></script>
	</head>
	<body onLoad="habbtn2('false');document.form2.frmgrpitmsel2.value='';document.form1.frmgrpitmsel.value=''">
		<cfinclude template="cabecalho.cfm">
			<span class="exibir"><strong>
			</strong></span>
			<table width="90%" border="0" align="center">
			<tr valign="baseline">
				<td colspan="6" class="exibir">&nbsp;</td>
			</tr>
			<tr valign="baseline">
				<td colspan="6" class="exibir"><div align="center"><strong class="titulo1">REGISTRO REINCIDÊNCIA GRUPO/ITEM NO PACIN</strong></div></td>
			</tr>
			<tr valign="baseline">
				<td colspan="6">&nbsp;</td>
			</tr>
			<tr>
				<td>
 					<cfoutput>				
						<cfif #form.frmmodal# eq 0>
							<cfset auxmodal = 'Presencial'>
						<cfelseif #form.frmmodal# eq 1>
							<cfset auxmodal = 'A Distância'>
						<cfelse>
							<cfset auxmodal = 'Mista'>			  
						</cfif>
					<table width="90%" border="0">
						<tr valign="baseline" align="center">
							<td><span class="titulos">Exercício: #form.frmano#</span></td>
							<!--- <td><span class="titulos">Tipo Unidade: #form.frmtipounid# - #rsgrpitmtp.TUN_Descricao#</span></td> --->
							<td><span class="titulos">Modalidade: #auxmodal#</span></td>		  
						</tr>
						</table>	
						<table width="90%" border="0">
						<tr valign="baseline">
							<td><span class="titulos">Grupo:</span></td>
							<td class="exibir">#auxgrp# - #rsgrpitmtp.Grp_Descricao#</td>
						</tr>	
						<tr valign="baseline">
							<td><span class="titulos">Item:</span></td>
							<td class="exibir">#auxitm# - #rsgrpitmtp.Itn_Descricao#</td>
						</tr>					
          
					</table>
					</cfoutput>
				</td>
			</tr>
         

        </table>

	  <table width="98%" border="0" align="center">
		<form action="Pacin_GrupoItemReincidem.cfm" method="post" target="_parent" name="form2">  
			<tr bgcolor="f7f7f7">
				<td colspan="8" align="center" bgcolor="f7f7f7" class="titulo1">&nbsp;</td>
			</tr>
			<tr bgcolor="f7f7f7">
				<td colspan="8" align="center" bgcolor="#B4B4B4" class="titulo1"><strong>GRUPO/ITEM REINCIDENTE(S) REGISTRADO(S)</strong></td>
			</tr>
			
			<tr class="titulosClaro">
				<td colspan="14" bgcolor="eeeeee" class="exibir"><cfoutput>Qtd. #rsgritreg.recordcount#</cfoutput></td>
			</tr>
        	<tr class="titulosClaro">
				<td colspan="14" bgcolor="eeeeee" class="exibir">
					<table width="98%" border="0">
						<tr bgcolor="#CCCCCC">
							<td width="4%" align="center" class="titulos"><div align="left">Exercício</div></td>
							<td width="25%" align="center" class="titulos"><div align="center">Grupo Descriçao</div></td>
							<td width="62%" align="center" class="titulos"><div align="center">Item Descrição</div></td>
							<!--- <td width="8%" colspan="3" align="center" class="titulos"><div align="left">Limpar todos(as)<label>&nbsp;<input name="cbtodos2" type="checkbox" id="cbtodos2" onClick="todos2()" value="cbtodos2" checked></label></div></td> --->
							<td width="8%" colspan="3" align="center" class="titulos"><div align="left">Desselecionar</div></td>
						</tr>

						<cfset auxretirar = 0>
						<cfset grpantes = ''>
						<cfset itmantes = ''>
						<cfoutput query="rsgritreg">	
							<cfset scor = 'f7f7f7'>		
							<tr class="exibir">
								<td>#rsgritreg.grp_ano#</td>
								<td>#rsgritreg.Itn_NumGrupo# - #trim(rsgritreg.Grp_Descricao)#</td>
								<td>#rsgritreg.Itn_NumItem# - #trim(rsgritreg.Itn_Descricao)#</td>
								<td>
									<cfif Itn_NumGrupo neq grpantes or Itn_NumItem neq itmantes>
										<input name="cbgrpitm2" type="checkbox" id="cbgrpitm2" onClick="habbtn2(this.checked)" value="#rsgritreg.Itn_NumGrupo#_#rsgritreg.Itn_NumItem#" checked>
									<cfelse>
										<cfset auxretirar = auxretirar + 1>
									</cfif>
								</td>  
							</tr>
							<cfif scor eq 'f7f7f7'>
							<cfset scor = 'CCCCCC'>
							<cfelse>
							<cfset scor = 'f7f7f7'>
							</cfif>		
							<cfset grpantes = #Itn_NumGrupo#>
							<cfset itmantes = #Itn_NumItem#>		
						</cfoutput>			
          			</table>
				</td>
        	</tr>
			<tr>
				<td>
					<div align="center"><button type="button" class="botao" onClick="history.back(2);">Fechar</button></div>
				</td>
				<td colspan="6">
					<div align="right">
					<button type="submit" class="botao" name="confirma2" onClick="document.form2.sacao2.value='sus';avaliar2()" disabled="disabled">Suspender Reincidência</button>
					</div>
				</td>
   			</tr>
			<input name="frmgrpitmsel2" type="hidden" id="frmgrpitmsel2" value="">
			<input name="frmtotreg2" type="hidden" id="frmtotreg2" value="<cfoutput>#(rsgritreg.recordcount - auxretirar)#</cfoutput>">
			<input name="sacao2" type="hidden" id="sacao2" value="">
<!---			<input name="frmtipounid" type="hidden" id="frmtipounid" value="<cfoutput>#form.frmtipounid#</cfoutput>"> --->
			<input name="frmano" type="hidden" id="frmano" value="<cfoutput>#form.frmano#</cfoutput>">
			<input name="frmgrpitm" type="hidden" id="frmgrpitm" value="<cfoutput>#form.frmgrpitm#</cfoutput>">
			<input name="frmmodal" type="hidden" id="frmmodal" value="<cfoutput>#form.frmmodal#</cfoutput>">
			<input name="auxgrp" type="hidden" id="auxgrp" value="<cfoutput>#auxgrp#</cfoutput>">
			<input name="auxitm" type="hidden" id="auxitm" value="<cfoutput>#auxitm#</cfoutput>">
		</form>	  
	  	<!---  --->
		<form action="Pacin_GrupoItemReincidem.cfm" method="post" target="_parent" name="form1">  
			<tr bgcolor="f7f7f7">
				<td colspan="8" align="center" bgcolor="f7f7f7" class="titulo1">&nbsp;</td>
			</tr>
			<tr bgcolor="f7f7f7">
				<td colspan="8" align="center" bgcolor="#B4B4B4" class="titulo1"><strong>GRUPO/ITEM POR TIPO DE UNIDADE PARA REGISTRO DE COINCIDENTES</strong></td>
			</tr>
			<tr class="titulosClaro">
				<td colspan="14" bgcolor="eeeeee" class="exibir"><cfoutput>Qtd. #rsgritliv.recordcount#</cfoutput></td>
			</tr>
			<tr bgcolor="#CCCCCC">
			  <td width="4%" align="center" class="titulos"><div align="left">Exercício</div></td>
			  <td width="25%" align="center" class="titulos"><div align="center">Grupo Descriçao</div></td>
			  <td width="62%" align="center" class="titulos"><div align="center">Item Descrição</div></td>
			  <td width="8%" colspan="3" align="center" class="titulos"><div align="left">Selecionar todos(as)<label>&nbsp;<input type="checkbox" name="cbtodos" onClick="todos()" value="cbtodos"></label></div></td>
          	</tr>
	  
        <cfoutput query="rsgritliv">
		  	<cfset scor = 'f7f7f7'>		
          	<tr>
				<td colspan="8" align="center" class="titulos">
					<table width="100%" border="0" align="left">
						<tr class="exibir" bgcolor="#scor#">
							<td width="4%">#rsgritliv.grp_ano#</td>
							<td width="25%">#rsgritliv.Itn_NumGrupo# - #trim(rsgritliv.Grp_Descricao)#</td>
							<td width="62%">#rsgritliv.Itn_NumItem# - #trim(rsgritliv.Itn_Descricao)#</td>
							<td width="8%" bgcolor="#scor#">
								<input type="checkbox" name="cbgrpitm" onClick="habbtn(this.checked)" value="#rsgritliv.Itn_NumGrupo#_#rsgritliv.Itn_NumItem#">
							</td>			  				  
                		</tr>
            		</table>
				</td>
          	</tr>
			<cfif scor eq 'f7f7f7'>
				<cfset scor = 'CCCCCC'>
			<cfelse>
				<cfset scor = 'f7f7f7'>
			</cfif>
        </cfoutput>
        <tr bgcolor="f7f7f7">
          <td colspan="8" align="center" class="titulos"><hr></td>
        </tr>
        <tr>
          <td>
              <div align="center"><div align="center"><button type="button" class="botao" onClick="history.back(2);">Fechar</button></div>
          </td>
          <td colspan="6">
             <div align="right">
               <button type="submit" class="botao" name="confirma" onClick="document.form1.sacao.value='inc';avaliar()" disabled="disabled">Confirmar Coincidência</button>
          </div></td>
        </tr>
        <tr>
          <td colspan="8" align="center" class="titulos"><hr></td>
        </tr>
		<input name="frmgrpitmsel" type="hidden" id="frmgrpitmsel" value="">
		<input name="frmtotreg" type="hidden" id="frmtotreg" value="<cfoutput>#rsgritliv.recordcount#</cfoutput>">
		<input name="sacao" type="hidden" id="sacao" value="">
		<input name="frmse" type="hidden" id="frmse" value="">
		<input name="frmano" type="hidden" id="frmano" value="<cfoutput>#form.frmano#</cfoutput>">
<!---		<input name="frmtipounid" type="hidden" id="frmtipounid" value="<cfoutput>#form.frmtipounid#</cfoutput>"> --->
		<input name="frmmodal" type="hidden" id="frmmodal" value="<cfoutput>#form.frmmodal#</cfoutput>">
		<input name="frmgrpitm" type="hidden" id="frmgrpitm" value="<cfoutput>#form.frmgrpitm#</cfoutput>">
		<input name="frmgrpitmdb" type="hidden" id="frmgrpitmdb" value="<cfoutput>#rsgrpitmtp.Itn_Reincidentes#</cfoutput>">
		<input name="auxgrp" type="hidden" id="auxgrp" value="<cfoutput>#auxgrp#</cfoutput>">
		<input name="auxitm" type="hidden" id="auxitm" value="<cfoutput>#auxitm#</cfoutput>">
		
</form> 	
	  <!--- FIM DA ÁREA DE CONTEÚDO --->
</table>
  <!--- Término da área de conteúdo --->
</body>
</html>

