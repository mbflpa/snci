<cfprocessingdirective pageEncoding ="utf-8"/>
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
   <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>          
	<!--- <cfoutput>#form.dr# #form.area_usu#</cfoutput> --->
	<cfquery name="qAcesso" datasource="#dsn_inspecao#">
		SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena
		FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
		WHERE Usu_DR = '#form.frmse#'
	</cfquery> 

<!---  --->
<cfif isDefined("Form.sacao") and #form.sacao# is 'inc'>
	<cfoutput>
		<cfset scont = 1>
		<cfset auxinic = 1>
		<cfset auxfim = 8>
		<cfloop condition="scont lte form.frmtotreg">
		  <cfset auxcodunid = mid(form.frmavaliar,auxinic,auxfim)>
		  <cfquery datasource="#dsn_inspecao#">
			UPDATE Unidades set Und_Ano_Avaliar = '#form.frmano#'
			where Und_Codigo = '#auxcodunid#' 
		  </cfquery>

		  <cfset auxinic = auxinic + 8> 
		  <cfset scont = scont + 1>
		</cfloop>
	</cfoutput> 
<cfset form.sacao = ''>	
</cfif>
<!---  --->
<cfif isDefined("Form.sacao2") and #form.sacao2# is 'sus'>
	<cfoutput>
		<cfset scont = 1>
		<cfset auxinic = 1>
		<cfset auxfim = 8>
		<cfloop condition="scont lte form.frmtotreg2">
		
		  <cfset auxcodunid = mid(form.frmavaliar2,auxinic,auxfim)>
		  			
			<cfquery name="rsAval" datasource="#dsn_inspecao#">		
				SELECT top 1 INP_NumInspecao
				FROM Inspecao
				WHERE INP_Unidade = '#auxcodunid#'
				order by INP_NumInspecao desc
			</cfquery>
            <cfset auxano = right(rsAval.INP_NumInspecao,4)>
		  <cfquery datasource="#dsn_inspecao#">
			UPDATE Unidades set Und_Ano_Avaliar = '#auxano#'
			where Und_Codigo = '#auxcodunid#' 
		  </cfquery> 
		  <cfset auxinic = auxinic + 8> 
		  <cfset scont = scont + 1>
		</cfloop>
	</cfoutput> 
<cfset form.sacao2 = ''>	
</cfif>

<!---  --->
	<cfquery name="rsUnidade" datasource="#dsn_inspecao#">
		SELECT TUN_Codigo, TUN_Descricao, Und_Codigo, Und_Descricao, Und_Ano_Avaliar, Und_Ano_Horas_Avaliar, Und_Ano_Pontos_Avaliar
		FROM (Unidades INNER JOIN Tipo_Unidades ON Und_TipoUnidade = TUN_Codigo) 
		WHERE (Und_Ano_Avaliar Is Null Or Und_Ano_Avaliar <='#form.frmano#') and Und_Status = 'A' 
		<cfif form.frmtipounid neq 'Todas'>
		and TUN_Codigo = '#form.frmtipounid#' 
		</cfif>
		and Und_CodDiretoria = '#form.frmse#'
		ORDER BY TUN_Descricao, Und_Ano_Pontos_Avaliar DESC, Und_Descricao
	</cfquery>
	
    <cfquery dbtype="query" name="rsUnidnotSel">
		SELECT Und_Codigo, Und_Descricao,Und_Ano_Horas_Avaliar, Und_Ano_Pontos_Avaliar
		FROM rsUnidade
		WHERE (Und_Ano_Avaliar Is Null Or Und_Ano_Avaliar < '#form.frmano#')
		ORDER BY TUN_Descricao, Und_Ano_Pontos_Avaliar DESC, Und_Descricao
	</cfquery>
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
	document.form1.frmavaliar.value = '';
	var totreg = document.form1.frmtotreg.value;
	document.form1.frmtotreg.value = 0;

	if (totreg == 1 && document.form1.cbavaliar.checked == true) {
		document.form1.frmavaliar.value = document.form1.frmavaliar.value + '' + document.form1.cbavaliar.value;
		document.form1.frmtotreg.value = 1;
	}

	for (x = 0 ; x <= totreg ; x++)	{
			if (document.form1.cbavaliar[x].checked == true) {
				document.form1.frmavaliar.value = document.form1.frmavaliar.value + '' + document.form1.cbavaliar[x].value;
				document.form1.frmtotreg.value++;
			}
	}
}
//=============================
function avaliar2(){
//alert('linha53');
	document.form2.frmavaliar2.value = '';
	var totreg = document.form2.frmtotreg2.value;
	document.form2.frmtotreg2.value = 0;

	if (totreg == 1 && document.form2.cbavaliar2.checked == true) {
		document.form2.frmavaliar2.value = document.form2.frmavaliar2.value + '' + document.form2.cbavaliar2.value;
		document.form2.frmtotreg2.value = 1;
	}

	for (x = 0 ; x <= totreg ; x++)	{
			if (document.form2.cbavaliar2[x].checked == true) {
				document.form2.frmavaliar2.value = document.form2.frmavaliar2.value + '' + document.form2.cbavaliar2[x].value;
				document.form2.frmtotreg2.value++;
			}
	}
}
//=============================
function todos(){
//alert('linha 70');
	var totreg = document.form1.frmtotreg.value;
	
	if (totreg == 1 && document.form1.cbtodos.checked == false) {document.form1.cbavaliar.checked = false; document.form1.confirma.disabled=true;} 
    if (totreg == 1 && document.form1.cbtodos.checked == true) {document.form1.cbavaliar.checked = true; document.form1.confirma.disabled=false;} 
	
	for (x = 0 ; x <= totreg ; x++)	{
	   if (document.form1.cbtodos.checked == true) {document.form1.cbavaliar[x].checked = true; document.form1.confirma.disabled=false;}
	   if (document.form1.cbtodos.checked == false) {document.form1.cbavaliar[x].checked = false; document.form1.confirma.disabled=true;}
	}	
}
//=============================
function todos2(){
//alert('linha 89');
//	var frm = document.forms[0];
	var totreg = document.form2.frmtotreg2.value;
//	alert(document.form2.frmtotreg2.value);
	if (totreg == 1 && document.form2.cbtodos2.checked == false) {document.form2.cbavaliar2.checked = false; document.form2.confirma2.disabled=true;} 
    if (totreg == 1 && document.form2.cbtodos2.checked == true) {document.form2.cbavaliar2.checked = true; document.form2.confirma2.disabled=false;} 
	
	for (x = 0 ; x <= totreg ; x++)	{
	   if (document.form2.cbtodos2.checked == true) {document.form2.cbavaliar2[x].checked = true; document.form2.confirma2.disabled=false;}
	   if (document.form2.cbtodos2.checked == false) {document.form2.cbavaliar2[x].checked = false; document.form2.confirma2.disabled=true;}
	}
		
}

//=============================
function habbtn(a){
//alert('linha 160');
	document.form1.confirma.disabled=true;
	var totreg = document.form1.frmtotreg.value;
	var auxtot = 0;
    
	if (totreg == 1 && document.form1.cbavaliar.checked == true) {document.form1.confirma.disabled=false;}
	
	for (x = 0 ; x <= totreg ; x++)	
	{
	   if (document.form1.cbavaliar[x].checked == true) 
	   {
	   auxtot = 1;
	   break
	   }
	}
	
   if (auxtot > 0) {document.form1.confirma.disabled=false;}
}

//=============================
function habbtn2(a){
//alert('linha 126');
	document.form2.confirma2.disabled=true;
	var totreg = document.form2.frmtotreg2.value;
//alert(document.form2.frmtotreg2.value);
	var auxtot = 0;
    
	if (totreg == 1 && document.form2.cbavaliar2.checked == true) {document.form2.confirma2.disabled=false;}
	
	for (x = 0 ; x <= totreg ; x++)	
	{
	   if (document.form2.cbavaliar2[x].checked == true) 
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

<body>


<cfinclude template="cabecalho.cfm">
	    <span class="exibir"><strong>
	    </strong></span>
        <table width="72%" border="0" align="center">
          <tr valign="baseline">
            <td colspan="6" class="exibir">&nbsp;</td>
          </tr>
          <tr valign="baseline">
            <td colspan="6" class="exibir"><div align="center"><strong class="titulo1">PROGRAMA&Ccedil;&Atilde;O DE UNIDADES PARA AVALIA&Ccedil;&Atilde;O NO PACIN</strong></div></td>
          </tr>
          <tr valign="baseline">
            <td colspan="6">&nbsp;</td>
          </tr>
	  
          <cfoutput>
            <tr valign="baseline">
              <td width="14%"><div align="right"><span class="titulos">Superintendência:</span></div></td>
              <td width="17%"><div align="left">
                <select name="dr" id="dr" class="form" disabled>
                  <option selected="selected" value="#qAcesso.Usu_DR#">#qAcesso.Dir_Sigla#</option>
                </select>
              </div></td>
              <td width="21%"><div align="right"><span class="titulos">Tipo de Unidade  :</span></div></td>
              <td width="25%"><div align="left">
                <select name="frmtipounid" id="frmtipounid" class="form" disabled>
                 <cfif form.frmtipounid eq 'Todas'>
				 	<option value="Todas" selected="selected">Todas</option>
				 <cfelse>
					<option selected="selected" value="#rsUnidade.TUN_Codigo#">#rsUnidade.TUN_Descricao#</option>
				 </cfif>
                </select>
              </div></td>
              <td width="6%"><div align="right"><span class="titulos">Exercício:</span></div></td>
              <td width="17%"><div align="left">
                <select name="frmano" id="frmano" class="form"" disabled>
                  <option value="#frmano#">#frmano#</option>
                </select>
              </div></td>
            </tr>
          </cfoutput>
        </table>

	  <table width="80%" border="0" align="center">
<cfquery dbtype="query" name="rsUnidSel">
	SELECT Und_Codigo, Und_Descricao, Und_Ano_Horas_Avaliar, Und_Ano_Pontos_Avaliar
	FROM rsUnidade
	WHERE Und_Ano_Avaliar ='#form.frmano#'
	ORDER BY TUN_Descricao
</cfquery>

<form action="Pacin_Unidades_Avaliacao.cfm" method="post" target="_parent" name="form2">  
        <tr bgcolor="f7f7f7">
          <td colspan="8" align="center" bgcolor="f7f7f7" class="titulo1">&nbsp;</td>
        </tr>
        <tr bgcolor="f7f7f7">
          <td colspan="8" align="center" bgcolor="#B4B4B4" class="titulo1"><strong>UNIDADES PREVISTAS PARA AVALIAÇÃO NO PACIN</strong>&nbsp;<cfoutput>#form.frmano#</cfoutput></td>
          <cfset sarquivo = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #right(CGI.REMOTE_USER,8)# & '.xls'>
    </tr>
        <tr class="titulosClaro">
          <td colspan="14" bgcolor="eeeeee" class="exibir"><cfoutput>Qtd. #rsUnidSel.recordcount#</cfoutput></td>
        </tr>
        <tr class="titulosClaro">
          <td colspan="14" bgcolor="eeeeee" class="exibir"><table width="98%" border="0">
            <tr bgcolor="#CCCCCC" class="titulos">
              <td>Cód. Unidade </td>
              <td>Nome da Unidade </td>
              <td><div align="center">Horas</div></td>
              <td><div align="center">Pontos</div></td>
              <td>Selecionar todos(as)
              <input name="cbtodos2" type="checkbox" id="cbtodos2" onClick="todos2()" value="cbtodos2"></td>
              <td>Avaliações realizadas </td>
            </tr>
			<cfset auxretirar = 0>
	<cfoutput query="rsUnidSel">	
			<cfquery name="rsAval" datasource="#dsn_inspecao#">		
				SELECT INP_DtInicInspecao, Right(INP_NumInspecao,4) as ano
				FROM Inspecao
				WHERE INP_Unidade = '#rsUnidSel.Und_Codigo#'
				ORDER BY Right(INP_NumInspecao,4) 
			</cfquery>
			<cfquery dbtype="query" name="rsExiste">
				SELECT INP_DtInicInspecao, ano
				FROM rsAval
				WHERE ano = '#form.frmano#'
			</cfquery>
            <cfset auxano = ''>
			<cfset habSN = 'S'>
				
			<cfloop query="rsAval">
			   <cfset auxano = auxano & ' ' & rsAval.ano>
			</cfloop>
		    <cfif rsExiste.recordcount gt 0>
				<cfset habSN = 'N'>
				<cfset auxretirar = auxretirar + 1>
		    </cfif>	
			<cfset permutaSN = 'N'>	
			<cfif form.frmano eq year(now())>
				<cfquery name="rsPermuta" datasource="#dsn_inspecao#">		
					SELECT PPU_Status,PPU_Motivo,Und_Descricao
					FROM PacinPermutaUnidade INNER JOIN Unidades ON PPU_PARAUnidade = Und_Codigo
					WHERE PPU_Ano='#form.frmano#' and PPU_DEUnidade='#rsUnidSel.Und_Codigo#' and PPU_Status='S'
				</cfquery>	
				<cfif rsPermuta.recordcount gt 0>
				  <cfset permutaSN = 'S'>
				</cfif>		 
			</cfif>	
		  	<cfset scor = 'f7f7f7'>		
            <tr class="titulos">
              <td>#Und_Codigo#</td>
              <td>#Und_Descricao#</td>
			  <cfset horas = Und_Ano_Horas_Avaliar>
              <td><div align="center">#horas#</div></td>
			  <cfset pontos = numberFormat(Und_Ano_Pontos_Avaliar,99.00)>
              <td><div align="center">#pontos#</div></td>
              <td>
			  <cfif permutaSN eq 'S'>
			     <span class="red_titulo">Solicitado Permuta para #rsPermuta.Und_Descricao#&nbsp;&nbsp;Motivo: #rsPermuta.PPU_Motivo#</span> 
			  <cfelseif habSN eq 'S'>
			 <input name="cbavaliar2" type="checkbox" id="cbavaliar2" onClick="habbtn2(this.checked)" value="#trim(Und_Codigo)#">
			  <cfelse>
			  Avaliação realizada em #dateformat(rsExiste.INP_DtInicInspecao,"DD/MM/YYYY")#
			  </cfif>			  </td>
              <td>#auxano#</td>
            </tr>
            <cfif scor eq 'f7f7f7'>
              <cfset scor = 'CCCCCC'>
              <cfelse>
              <cfset scor = 'f7f7f7'>
            </cfif>				
	</cfoutput>			
          </table></td>
        </tr>
<tr>
          <td>
              <div align="center">
                <input name="Submit1" type="button" class="form" id="Submit1" value="FECHAR" onClick="window.close()">
          </div></td>
          <td colspan="6">
             <div align="right">
               <button type="submit" class="botao" name="confirma2" onClick="document.form2.sacao2.value='sus';avaliar2()" disabled="disabled">Suspender Programação de Avaliação </button>
          </div></td>
    </tr>
    	<input name="frmavaliar2" type="hidden" id="frmavaliar2" value="">
		<input name="frmtotreg2" type="hidden" id="frmtotreg2" value="<cfoutput>#(rsUnidSel.recordcount - auxretirar)#</cfoutput>">
		<input name="sacao2" type="hidden" id="sacao2" value="">
		<input name="frmse" type="hidden" id="frmse" value="<cfoutput>#form.frmse#</cfoutput>">
		<input name="frmano" type="hidden" id="frmano" value="<cfoutput>#form.frmano#</cfoutput>">
		<input name="frmtipounid" type="hidden" id="frmtipounid" value="<cfoutput>#form.frmtipounid#</cfoutput>"> 
</form>	  
	  <!---  --->
<form action="Pacin_Unidades_Avaliacao.cfm" method="post" target="_parent" name="form1">  

        <tr bgcolor="f7f7f7">
          <td colspan="8" align="center" bgcolor="f7f7f7" class="titulo1">&nbsp;</td>
        </tr>
        <tr bgcolor="f7f7f7">
          <td colspan="8" align="center" bgcolor="#B4B4B4" class="titulo1"><strong>UNIDADES SEM PREVISÃO DE AVALIAÇÃO <strong>NO PACIN </strong></strong><cfoutput>#form.frmano#</cfoutput></td>
        </tr>

          <tr bgcolor="#CCCCCC">
            <td width="8%" align="center" class="titulos"><div align="left">Cód. Unidade </div></td>
            <td width="21%" align="center" class="titulos"><div align="left">Nome da Unidade </div></td>
            <td width="4%" align="center" class="titulos"><div align="center">Horas</div></td>
            <td width="6%" align="center" class="titulos"><div align="left">Pontos</div></td>
            <td colspan="3" align="center" class="titulos"><div align="left">Selecionar todos(as)  
              <label>
              &nbsp;
              <input type="checkbox" name="cbtodos" onClick="todos()" value="cbtodos">
              </label>
            </div></td>
            <td width="28%" align="center" class="titulos">Avaliações realizadas </td>
          </tr>
		  
        <cfoutput query="rsUnidnotSel">
			<cfquery name="rsAval" datasource="#dsn_inspecao#">		
				SELECT INP_Unidade, Right(INP_NumInspecao,4) as ano
				FROM Inspecao
				WHERE INP_Unidade = '#Und_Codigo#'
				ORDER BY Right(INP_NumInspecao,4)
			</cfquery>

            <cfset auxano = ''>
			<cfloop query="rsAval">
			    <cfset auxano = auxano & ' ' & rsAval.ano>
			</cfloop>	
			<cfset exibirlinSN = 'S'>			
			<cfif form.frmano gt year(now())>
				<cfquery dbtype="query" name="rsSelAnoAtual">
					SELECT Und_Codigo, Und_Descricao
					FROM rsUnidade
					WHERE Und_Ano_Avaliar ='#year(now())#' and Und_Codigo = '#rsAval.INP_Unidade#'
				</cfquery>	
				<cfif rsSelAnoAtual.recordcount gt 0>		
					<cfquery name="rsExibir" datasource="#dsn_inspecao#">		
						SELECT Und_Codigo, Und_Ano_Avaliar, INP_Unidade, INP_NumInspecao
						FROM Unidades INNER JOIN Inspecao ON Und_Codigo = INP_Unidade
						WHERE Und_Codigo = '#rsAval.INP_Unidade#' AND Und_Ano_Avaliar ='#year(now())#' AND INP_NumInspecao Like '%#year(now())#'
						order by INP_NumInspecao desc
					</cfquery>
					<cfif rsExibir.recordcount lte 0>
					  <cfset exibirlinSN = 'N'>
					</cfif>
				</cfif>				
			</cfif>	
			<cfset permutaSN = 'N'>	
			<cfif form.frmano eq year(now())>
				<cfquery name="rsPermuta2" datasource="#dsn_inspecao#">		
					SELECT PPU_Status,PPU_Motivo,Und_Descricao
					FROM PacinPermutaUnidade INNER JOIN Unidades ON PPU_DEUnidade = Und_Codigo
					WHERE PPU_Ano='#form.frmano#' and PPU_PARAUnidade='#rsUnidnotSel.Und_Codigo#' and PPU_Status='S'
				</cfquery>
				<cfif rsPermuta2.recordcount gt 0>
				  <cfset permutaSN = 'S'>
				</cfif>		 
			</cfif>	
		  	<cfset scor = 'f7f7f7'>		

          	<tr>
            <td colspan="8" align="center" class="titulos">
			<table width="100%" border="0" align="left">
                <tr class="titulos" bgcolor="#scor#">
                  <td width="81">#Und_Codigo#</td>
                  <td width="203">#trim(Und_Descricao)#</td>
				  <cfset horas = Und_Ano_Horas_Avaliar>
				  <td width="46"><div align="right">#horas#</div></td>
				  <cfset pontos = numberFormat(Und_Ano_Pontos_Avaliar,99.00)>
				  <td width="62"><div align="center">#pontos#</div></td>
				  <td width="489" bgcolor="#scor#">
				  	<cfif permutaSN eq 'S'>
			     		<span class="red_titulo">Solicitado Permutar à(o) #rsPermuta2.Und_Descricao#&nbsp;&nbsp;Motivo: #rsPermuta2.PPU_Motivo#</span>
					<cfelseif exibirlinSN eq 'S'>
						<input type="checkbox" name="cbavaliar" onClick="habbtn(this.checked)" value="#trim(Und_Codigo)#">
					<cfelse>
						Avaliação programada e ainda não realizada no Exercício de #year(now())#
				  </cfif>			  </td>			  				  
                  <td width="127">#auxano#</td>
                </tr>
            </table></td>
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
              <div align="center">
                <input name="Submit1" type="button" class="form" id="Submit1" value="FECHAR" onClick="window.close()">
          </div></td>
          <td colspan="6">
             <div align="right">
               <button type="submit" class="botao" name="confirma" onClick="document.form1.sacao.value='inc';avaliar()" disabled="disabled">Confirmar Programação de Avaliação </button>
          </div></td>
        </tr>
        <tr>
          <td colspan="8" align="center" class="titulos"><hr></td>
        </tr>
		<input name="frmavaliar" type="hidden" id="frmavaliar" value="">
		<input name="frmtotreg" type="hidden" id="frmtotreg" value="<cfoutput>#rsUnidnotSel.recordcount#</cfoutput>">
		<input name="sacao" type="hidden" id="sacao" value="">
		<input name="frmse" type="hidden" id="frmse" value="<cfoutput>#form.frmse#</cfoutput>">
		<input name="frmano" type="hidden" id="frmano" value="<cfoutput>#form.frmano#</cfoutput>">
		<input name="frmtipounid" type="hidden" id="frmtipounid" value="<cfoutput>#form.frmtipounid#</cfoutput>">
</form>

<!--- <cfquery dbtype="query" name="rsUnidSel">
	SELECT Und_Codigo, Und_Descricao
	FROM rsUnidade
	WHERE Und_Ano_Avaliar ='#form.frmano#'
	ORDER BY TUN_Descricao
</cfquery>

<form action="Pacin_Unidades_Avaliacao.cfm" method="post" target="_parent" name="form2">  
        <tr bgcolor="f7f7f7">
          <td colspan="6" align="center" bgcolor="f7f7f7" class="titulo1">&nbsp;</td>
        </tr>
        <tr bgcolor="f7f7f7">
          <td colspan="6" align="center" bgcolor="#B4B4B4" class="titulo1">  Unidade(s) CONFIRMADAS para o exercÍcio de <cfoutput>#form.frmano#</cfoutput></td>
          <cfset sarquivo = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #right(CGI.REMOTE_USER,8)# & '.xls'>
    </tr>
        <tr class="titulosClaro">
          <td colspan="12" bgcolor="eeeeee" class="exibir"><cfoutput>Qtd. #rsUnidSel.recordcount#</cfoutput></td>
        </tr>
        <tr class="titulosClaro">
          <td colspan="12" bgcolor="eeeeee" class="exibir"><table width="98%" border="0">
            <tr bgcolor="#CCCCCC" class="titulos">
              <td>Cód. Unidade </td>
              <td>Nome da Unidade </td>
              <td>Selecionar todos(as)
              <input name="cbtodos2" type="checkbox" id="cbtodos2" onClick="todos2()" value="cbtodos2"></td>
              <td>Avaliações realizadas </td>
            </tr>
			<cfset auxretirar = 0>
	<cfoutput query="rsUnidSel">	
			<cfquery name="rsAval" datasource="#dsn_inspecao#">		
				SELECT INP_DtInicInspecao, Right(INP_NumInspecao,4) as ano
				FROM Inspecao
				WHERE INP_Unidade = '#rsUnidSel.Und_Codigo#'
				ORDER BY Right(INP_NumInspecao,4) 
			</cfquery>
			<cfquery dbtype="query" name="rsExiste">
				SELECT INP_DtInicInspecao, ano
				FROM rsAval
				WHERE ano = '#form.frmano#'
			</cfquery>
            <cfset auxano = ''>
			<cfset habSN = 'S'>
				
			<cfloop query="rsAval">
			   <cfset auxano = auxano & ' ' & rsAval.ano>
			</cfloop>
		    <cfif rsExiste.recordcount gt 0>
				<cfset habSN = 'N'>
				<cfset auxretirar = auxretirar + 1>
		    </cfif>			
		  	<cfset scor = 'f7f7f7'>		
            <tr class="titulos">
              <td>#Und_Codigo#</td>
              <td>#Und_Descricao#</td>
              <td>
			  <cfif habSN eq 'S'>
			 <input name="cbavaliar2" type="checkbox" id="cbavaliar2" onClick="habbtn2(this.checked)" value="#trim(Und_Codigo)#">
			  <cfelse>
			  Avaliação realizada em #dateformat(rsExiste.INP_DtInicInspecao,"DD/MM/YYYY")#
			  </cfif>
			  </td>
              <td>#auxano#</td>
            </tr>
            <cfif scor eq 'f7f7f7'>
              <cfset scor = 'CCCCCC'>
              <cfelse>
              <cfset scor = 'f7f7f7'>
            </cfif>				
	</cfoutput>			
          </table></td>
        </tr>
<tr>
          <td>
              <div align="center">
                <input name="Submit1" type="button" class="form" id="Submit1" value="FECHAR" onClick="window.close()">
          </div></td>
          <td colspan="4">
             <div align="right">
               <button type="submit" class="botao" name="confirma2" onClick="document.form2.sacao2.value='sus';avaliar2()" disabled="disabled">Suspender Programação de Avaliação </button>
          </div></td>
    </tr>
    	<input name="frmavaliar2" type="hidden" id="frmavaliar2" value="">
		<input name="frmtotreg2" type="hidden" id="frmtotreg2" value="<cfoutput>#(rsUnidSel.recordcount - auxretirar)#</cfoutput>">
		<input name="sacao2" type="hidden" id="sacao2" value="">
		<input name="frmse" type="hidden" id="frmse" value="<cfoutput>#form.frmse#</cfoutput>">
		<input name="frmano" type="hidden" id="frmano" value="<cfoutput>#form.frmano#</cfoutput>">
		<input name="frmtipounid" type="hidden" id="frmtipounid" value="<cfoutput>#form.frmtipounid#</cfoutput>"> 
</form>	 --->	  	
	  <!--- FIM DA ÁREA DE CONTEÚDO --->
</table>
  

  <!--- Término da área de conteúdo --->
</body>
</html>

