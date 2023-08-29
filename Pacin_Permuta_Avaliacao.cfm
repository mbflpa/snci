<cfprocessingdirective pageEncoding ="utf-8"/>
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
   <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>  
	<!--- <cfoutput>#form.dr# #form.area_usu#</cfoutput> --->
 <cfif isDefined("url.frmse") and #url.frmse# neq ''>
   <cfset form.frmse = url.frmse>
   <cfset form.frmano = url.frmano>
   <cfset form.frmtipounid = url.frmtipounid>      
 </cfif>
	
	<cfquery name="qAcesso" datasource="#dsn_inspecao#">
		SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena
		FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
		WHERE Usu_DR = '#form.frmse#'
	</cfquery> 


	<cfquery name="rsUnidade" datasource="#dsn_inspecao#">
		SELECT TUN_Codigo, TUN_Descricao, Und_Codigo, Und_Descricao, Und_Ano_Avaliar, Und_Ano_Horas_Avaliar, Und_Ano_Pontos_Avaliar
		FROM Tipo_Unidades INNER JOIN Unidades ON TUN_Codigo = Und_TipoUnidade
		WHERE (Und_Ano_Avaliar Is Null Or Und_Ano_Avaliar <='#form.frmano#') and Und_Status = 'A' 
		<cfif form.frmtipounid neq 'Todas'>
		and TUN_Codigo = '#form.frmtipounid#' 
		</cfif>
		and Und_CodDiretoria = '#form.frmse#'
		ORDER BY Und_Ano_Pontos_Avaliar desc, Und_Descricao
	</cfquery>
	
    <cfquery dbtype="query" name="rsUnidnotSel">
		SELECT Und_Codigo, Und_Descricao, Und_Ano_Horas_Avaliar, Und_Ano_Pontos_Avaliar
		FROM rsUnidade
		WHERE (Und_Ano_Avaliar Is Null Or Und_Ano_Avaliar < '#form.frmano#')
		ORDER BY Und_Ano_Pontos_Avaliar desc, Und_Descricao
	</cfquery>
	<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>Sistema Nacional de Controle Interno</title>
	<link href="../../estilo.css" rel="stylesheet" type="text/css">
	<link href="css.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
//============================================	
function validaForm() {

	if (document.form1.frmunidpara.value != document.form1.frmunidparatopo.value){
   		var auxcam = 'A próxima unidade indicada para permutar por possuir maior pontuação é ' + document.form1.frmunidparatopo.value + ' - ' + document.form1.frmunidparatoponome.value + '\n\n Você selecionou uma outra unidade com menor ranking de pontuação\n\nConfirma o envio de solicitação de permuta mesmo assim?';

		
		if (confirm ('            Atenção!\n\n' + auxcam))
		{
			 return true;
		}
		else
		   {
			 return false;
		  }
		}
//return false;
}
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
function habbtn(a){
//alert('linha 66' + a);
//alert(document.form1.frmunidparatopo.value);
	document.form1.frmunidde.value=a;		
	var totreg = document.form1.frmtotreg.value;
	//alert(totreg);
	var auxtot = 0;
	if (totreg == 1){
	 document.form1.rdavaliarpara.disabled = false;
	 document.form1.rdavaliarpara.checked = true;
	 habbtn2(document.form1.rdavaliarpara.value);
	}
	if (totreg > 1){
	 document.form1.rdavaliarpara[0].disabled = false;
	 document.form1.rdavaliarpara[0].checked = true;
	 habbtn2(document.form1.rdavaliarpara[0].value);
	}
	
	for (x = 0 ; x <= totreg ; x++)	
	{
//	 alert(x);
	   document.form1.rdavaliarpara[x].disabled = false;
	   auxtot = 1;

	}

}

//=============================
function habbtn2(a){
//alert(a);
	document.form1.confirma.disabled=false;
	document.form1.frmunidpara.value=a;
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
            <td colspan="6" class="exibir"><div align="center"><span class="titulo2"><strong class="titulo1">SOLICITAR PERMUTA POR  </strong> <span class="titulo1">AVALIA&Ccedil;&Atilde;O DE UNIDADE NO PACIN</span></span></div></td>
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
            ORDER BY Und_Ano_Pontos_Avaliar desc, Und_Descricao
          </cfquery>
          <form action="" method="post" target="_parent" name="form2">
            <tr bgcolor="f7f7f7">
              <td colspan="8" align="center" bgcolor="f7f7f7" class="titulo1">&nbsp;</td>
            </tr>
            <tr bgcolor="f7f7f7">
              <td colspan="8" align="center" bgcolor="#CCCCCC" class="titulo1"><strong>UNIDADES PREVISTAS PARA AVALIAÇÃO NO PACIN</strong>&nbsp;<cfoutput>#form.frmano#</cfoutput></td>
              <cfset sarquivo = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #right(CGI.REMOTE_USER,8)# & '.xls'>
            </tr>
            <tr class="titulosClaro">
              <td colspan="14" bgcolor="eeeeee" class="exibir"><table width="100%" border="0">
                  <tr bgcolor="#CCCCCC" class="titulos">
                    <td width="8%">Cód. Unidade </td>
                    <td width="32%">Nome da Unidade </td>
                    <td width="5%"><div align="center">Horas</div></td>
                    <td width="6%"><div align="center">Pontos</div></td>
                    <td width="30%">Clique para Selecionar</td>
                    <td width="19%">Avaliações realizadas </td>
                  </tr>
                  <cfset auxretirar = 0>
                  <cfoutput query="rsUnidSel">
					<cfquery name="rsPermuta" datasource="#dsn_inspecao#">		
						SELECT PPU_Status,PPU_Motivo,Und_Descricao
						FROM PacinPermutaUnidade INNER JOIN Unidades ON PPU_PARAUnidade = Und_Codigo
						WHERE PPU_Ano='#form.frmano#' and PPU_DEUnidade='#rsUnidSel.Und_Codigo#' and PPU_Status='S'
					</cfquery>
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
                    <cfif habSN eq 'S'>
                      <tr class="titulos" bgcolor="#scor#">
                        <td>#Und_Codigo#</td>
                        <td>#Und_Descricao#</td>
						<cfset horas = Und_Ano_Horas_Avaliar>
                        <td><div align="center">#horas#</div></td>
						<cfset pontos = numberFormat(Und_Ano_Pontos_Avaliar,99.00)>
                        <td><div align="center">#pontos#</div></td>
                        <td bgcolor="#scor#">
						<cfif rsPermuta.PPU_Status eq 'S'>
						    <span class="red_titulo">Será Permutado por #rsPermuta.Und_Descricao#&nbsp;&nbsp;Motivo: #rsPermuta.PPU_Motivo#</span> 
                        <cfelse>
							<label>
								<input name="rdavaliarde" type="radio" id="cbavaliar2" onClick="habbtn(this.value)" value="#trim(Und_Codigo)#">
							</label>
						</cfif>						</td>
                        <td>#auxano#</td>
                      </tr>
                      <cfif scor eq 'f7f7f7'>
                        <cfset scor = 'CCCCCC'>
                        <cfelse>
                        <cfset scor = 'f7f7f7'>
                      </cfif>
                    </cfif>
                  </cfoutput>
              </table></td>
            </tr>
            <tr>
              <td colspan="8"></td>
            </tr>
			<tr class="titulosClaro">
              <td colspan="14" bgcolor="eeeeee" class="exibir"><cfoutput>Qtd. #(rsUnidSel.recordcount - auxretirar)#</cfoutput></td>
            </tr>
          </form>
	      <!---  --->
          <form action="Pacin_Permuta_Avaliacao1.cfm" method="post" target="_self" name="form1" onSubmit="return validaForm()">
            <tr bgcolor="f7f7f7">
              <td colspan="8" align="center" bgcolor="f7f7f7"><hr></td>
            </tr>
            <tr bgcolor="f7f7f7">
              <td colspan="8" align="center" bgcolor="#CCCCCC" class="titulo1"><strong>UNIDADES SEM PREVISÃO DE AVALIAÇÃO <strong>NO PACIN</strong></strong>&nbsp;<cfoutput>#form.frmano#</cfoutput></td>
            </tr>
            <tr bgcolor="#CCCCCC">
              <td width="8%" align="center" class="titulos"><div align="left">Cód. Unidade </div></td>
              <td width="32%" align="center" class="titulos"><div align="left">Nome da Unidade </div></td>
              <td width="6%" align="center" class="titulos"><div align="center">Horas</div></td>
              <td width="5%" align="center" class="titulos"><div align="center">Pontos</div></td>
              <td colspan="3" align="center" class="titulos"><div align="left">Clique para Selecionar a Permuta
                <label> &nbsp;</label>
              </div></td>
              <td width="19%" align="center" class="titulos"><div align="left">Avaliações realizadas </div></td>
            </tr>
            <cfoutput query="rsUnidnotSel">
				<cfquery name="rsPermuta2" datasource="#dsn_inspecao#">		
					SELECT PPU_Status,PPU_Motivo,Und_Descricao,Und_Ano_Horas_Avaliar, Und_Ano_Pontos_Avaliar
					FROM PacinPermutaUnidade INNER JOIN Unidades ON PPU_DEUnidade = Und_Codigo
					WHERE PPU_Ano='#form.frmano#' and PPU_PARAUnidade='#rsUnidnotSel.Und_Codigo#' and PPU_Status='S'
				</cfquery>			
              <cfquery name="rsAval" datasource="#dsn_inspecao#">
                SELECT INP_Unidade, Right(INP_NumInspecao,4) as ano
                FROM Inspecao
                WHERE INP_Unidade = '#rsUnidnotSel.Und_Codigo#'
                ORDER BY Right(INP_NumInspecao,4)
              </cfquery>
              <cfset auxano = ''>
              <cfloop query="rsAval">
                <cfset auxano = auxano & ' ' & rsAval.ano>
              </cfloop>
              <cfset exibirlinSN = 'S'>
              <cfif form.frmano gt year(now())>
                <cfquery dbtype="query" name="rsSelAnoAtual">
                  SELECT Und_Codigo, Und_Descricao, Und_Ano_Horas_Avaliar, Und_Ano_Pontos_Avaliar
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
              <cfset scor = 'f7f7f7'>
			  <cfif exibirlinSN eq 'S'>
				  <tr>
					<td colspan="8" align="center" class="titulos">
					<table width="100%" border="0" align="left">
						<tr class="titulos" bgcolor="#scor#">
						  <td width="84">#Und_Codigo#</td>
						  <td width="331">#trim(Und_Descricao)#</td>
						  <cfset horas = Und_Ano_Horas_Avaliar>
						  <td width="46"><div align="center">#horas#</div></td>
						  <cfset pontos = numberFormat(Und_Ano_Pontos_Avaliar,99.00)>
						  <td width="56"><div align="center">#pontos#</div></td>
						  <td width="312" bgcolor="#scor#">
						 	<cfif rsPermuta2.PPU_Status eq 'S'>
						    	<span class="red_titulo">Irá Permutar à(o) #rsPermuta2.Und_Descricao#&nbsp;&nbsp;Motivo: #rsPermuta2.PPU_Motivo#</span> 
                        	<cfelse>
							<label>
							  <input name="rdavaliarpara" type="radio" onClick="habbtn2(this.value)" value="#trim(Und_Codigo)#" disabled>
							</label>
						    </cfif>
							</td>
						  <td width="193">#auxano#</td>
						</tr>
					</table>
					</td>
				  </tr>
				  <cfif scor eq 'f7f7f7'>
					<cfset scor = 'CCCCCC'>
					<cfelse>
					<cfset scor = 'f7f7f7'>
				  </cfif>
			</cfif>					  
            </cfoutput>
			<tr class="titulosClaro">
              <td colspan="14" bgcolor="eeeeee" class="exibir"><cfoutput>Qtd. #rsUnidnotSel.recordcount#</cfoutput></td>
            </tr>
            <tr bgcolor="f7f7f7">
              <td colspan="8" align="center" class="titulos"><hr></td>
            </tr>
            <tr>
              <td><div align="center">
                  <input name="Submit1" type="button" class="form" id="Submit1" value="FECHAR" onClick="window.close()">
              </div></td>
              <td colspan="8">
                <div align="center">
                  <button type="submit" class="botao" name="confirma" onClick="troca()" disabled="disabled">Solicitar Permuta de Avaliação </button>
                </div></td>
			</tr>
            <tr>
              <td colspan="8" align="center" class="titulos"><hr></td>
            </tr>
            <input name="frmtotreg" type="hidden" id="frmtotreg" value="<cfoutput>#rsUnidnotSel.recordcount#</cfoutput>">
            <input name="frmse" type="hidden" id="frmse" value="<cfoutput>#form.frmse#</cfoutput>">
            <input name="frmano" type="hidden" id="frmano" value="<cfoutput>#form.frmano#</cfoutput>">
            <input name="frmtipounid" type="hidden" id="frmtipounid" value="<cfoutput>#form.frmtipounid#</cfoutput>">
			<input name="frmunidde" type="hidden" id="frmunidde" value="">
			<input name="frmunidpara" type="hidden" id="frmunidpara" value="">
			<input name="frmunidparatopo" type="hidden" id="frmunidparatopo" value="<cfoutput>#rsUnidnotSel.Und_Codigo#</cfoutput>">
			<input name="frmunidparatoponome" type="hidden" id="frmunidparatoponome" value="<cfoutput>#rsUnidnotSel.Und_Descricao#</cfoutput>">
          </form>
          <!--- FIM DA ÁREA DE CONTEÚDO --->
</table>
	    <!--- Término da área de conteúdo --->
</body>
</html>

