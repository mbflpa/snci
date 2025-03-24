<cfprocessingdirective pageEncoding ="utf-8"/>
<cfif isDefined("form.frmx_sacao") and form.frmx_sacao is "vis">
	<cfquery name="rsVis" datasource="#dsn_inspecao#">
		SELECT AVGR_ANO, AVGR_ID, AVGR_DT_INICIO, AVGR_DT_FINAL, AVGR_GRUPOACESSO, AVGR_AVISO, AVGR_status, AVGR_username, AVGR_TITULO
		FROM AvisosGrupos
		WHERE AVGR_ANO = '#form.frmx_ano#' AND AVGR_ID = #form.frmx_id#
		ORDER BY AVGR_ANO DESC, AVGR_DT_INICIO DESC
	</cfquery>
</cfif>

<!--- fim area de registros em banco --->
	<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>Sistema Nacional de Controle Interno</title>
	<link href="../../estilo.css" rel="stylesheet" type="text/css">
	<link href="css.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
//=============================
	function visualizar(a,b,c){
	//alert(a + b + c);
	//return false;
		document.formx.frmx_ano.value=a;
		document.formx.frmx_id.value=b;
		document.formx.frmx_sacao.value=c;
		document.formx.submit(); 
	}
</script>
<script language="JavaScript" src="../../mm_menu.js"></script>
	</head>

<body>
<cfif isDefined("form.frmx_sacao") and form.frmx_sacao is "vis">
	<cfquery name="rsVis" datasource="#dsn_inspecao#">
			SELECT AVGR_ANO, AVGR_ID, AVGR_DT_INICIO, AVGR_DT_FINAL, AVGR_GRUPOACESSO, AVGR_AVISO, AVGR_status, AVGR_username, AVGR_TITULO
			FROM AvisosGrupos
			WHERE AVGR_ANO = '#form.frmx_ano#' AND AVGR_ID = #form.frmx_id#
	</cfquery>
	<cfif rsVis.recordcount gt 0>
		<cfif len(rsVis.AVGR_ID) is 1>
			<cfset auxid = '000' & rsVis.AVGR_ID>
		<cfelseif len(rsVis.AVGR_ID) is 2>
			<cfset auxid = '00' & rsVis.AVGR_ID>
		<cfelseif len(rsVis.AVGR_ID) is 3>
			<cfset auxid = '0' & rsVis.AVGR_ID>		
		</cfif>
		<cfset auxDTINI = dateformat(rsVis.AVGR_DT_INICIO,"DD/MM/YYYY")>
		<cfset auxDTFIN = dateformat(rsVis.AVGR_DT_FINAL,"DD/MM/YYYY")>
		<cfset auxanoid = rsVis.AVGR_ANO & '/' & auxid> 
		<cfset auxgrpacesso = rsVis.AVGR_GRUPOACESSO> 
		
		<cfif rsVis.AVGR_status eq 'A'>
			<cfset auxsitu = 'Ativado'>
		<cfelse>
			<cfset auxsitu = 'Desativado'>	
		</cfif>		
		<cfset auxtit = rsVis.AVGR_TITULO>
		<cfset auxaviso = rsVis.AVGR_AVISO>

	</cfif>
<cfelse>
    <cfset auxDTINI = ''>
	<cfset auxDTFIN = ''>	
	<cfset auxanoid = ''> 
	<cfset auxgrpacesso = ''> 
	<cfset auxsitu = ''>
	<cfset auxtit = ''>
	<cfset auxaviso = ''>
	
</cfif>
 <cfinclude template="cabecalho.cfm"> 
 <cfoutput>
	<form name="form1" method="post" action="index.cfm?opcao=permissao15" onSubmit="return valida_form()">  
        <table width="80%" border="0" align="center" bordercolor="##FFFFFF">
          <tr valign="baseline">
            <td colspan="3" class="exibir"><div align="center"><span class="titulo1"><strong>AVISOS - SNCI </strong></span></div></td>
          </tr>
          <tr valign="baseline">
            <td colspan="3" class="titulos">
                    <div align="left">
                      <input name="Submit1" type="button" class="form" id="Submit1" value="FECHAR" onClick="window.close()">
                  </div>			</td>
          </tr>
          <tr valign="baseline">
            <td colspan="3" class="titulos">&nbsp;</td>
          </tr>
          <tr valign="baseline">
            <td colspan="3" class="titulos">&nbsp;</td>
          </tr>
          <tr valign="baseline">
            <td width="6%" class="titulos">Ano/Num.</td>
            <td width="6%"><span class="titulos">Início</span></td>
            <td width="88%"><span class="titulos">Término</span></td>
          </tr>
      
            <tr valign="baseline" bgcolor="##CDCDCD" class="titulos">
              <td>#auxanoid#</td>
              <td>#auxDTINI#</td>
              <td>#auxDTFIN#</td>
            </tr>
            <tr valign="baseline">
              <td colspan="3">&nbsp;</td>
            </tr>
            <tr valign="baseline">
              <td colspan="3"><span class="titulos">Título </span></td>
            </tr>
            <tr valign="baseline" bgcolor="##CDCDCD">
              <td colspan="3" class="titulos">#auxtit#</td>
            </tr>
         
            <tr valign="baseline">
              <td colspan="3">&nbsp;</td>
            </tr>
          <tr valign="baseline">
            <td colspan="3"><span class="titulos">Mensagem</span></td>
          </tr>
          <tr valign="baseline">
            <td colspan="3"><textarea name="frmmensagem" cols="248" rows="6" class="titulos" id="frmmensagem" readonly="readonly">#auxaviso#</textarea></td>
          </tr>
          <tr valign="baseline">
            <td colspan="3"><hr></td>
          </tr>
        </table>
</form>
</cfoutput>

	<cfquery name="qUsuario" datasource="#dsn_inspecao#">
		SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena 
		FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
		WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
	</cfquery>
	
	<cfset auxdt = createodbcdate(CreateDate(year(now()),month(now()),day(now())))>

	<cfquery name="rsAvisos" datasource="#dsn_inspecao#">
		SELECT AVGR_ANO, AVGR_ID, AVGR_TITULO, AVGR_DT_INICIO, AVGR_DT_FINAL, AVGR_GRUPOACESSO, AVGR_AVISO, AVGR_status, AVGR_ANEXO, AVGR_DT_DES 
		FROM AvisosGrupos
		WHERE  (AVGR_status <> 'E') and (AVGR_GRUPOACESSO ='#qUsuario.Usu_GrupoAcesso#' OR AVGR_GRUPOACESSO='GERAL' OR 
(AVGR_GRUPOACESSO='GESTORINSPETOR' AND ('#qUsuario.Usu_GrupoAcesso#'='GESTORES' Or '#qUsuario.Usu_GrupoAcesso#'='INSPETORES'))
OR (AVGR_GRUPOACESSO='GESTORINSPETORANALISTA' AND ('#qUsuario.Usu_GrupoAcesso#'='GESTORES' Or '#qUsuario.Usu_GrupoAcesso#'='INSPETORES' Or '#qUsuario.Usu_GrupoAcesso#'='ANALISTAS')))
ORDER BY AVGR_ANO DESC, AVGR_DT_INICIO DESC, AVGR_ID, AVGR_GRUPOACESSO
	</cfquery>
	
	  <table width="81%" border="0" align="center">
	  <tr class="titulosClaro">
	    <td colspan="11" bgcolor="eeeeee" class="exibir">Qtd.: <cfoutput>#rsAvisos.recordCount#</cfoutput></td>
    </tr>
	    <tr bgcolor="#B4B4B4" class="titulos" align="center">
	  	<td width="8%"><div align="center">Ano/Num.</div></td>
		<td width="8%">Início</td>
		<td width="9%"><div align="center">Término</div></td>
		<td width="53%"><div align="left">Título</div>		  <div align="left"></div></td>
		<td width="14%">+ Detalhes(clicar botão) </td>
		<td width="8%">Anexo</td>
	    </tr>

  
	      <cfset scor = 'f7f7f7'>
		  <cfoutput query="rsAvisos">
		  <cfif AVGR_status eq 'D' and AVGR_DT_DES eq ''>
		  <cfelse>
		  
 		     <form action="" method="POST" name="formexc">
				<cfif len(AVGR_ID) is 1>
					<cfset auxid = '000' & AVGR_ID>
				<cfelseif len(AVGR_ID) is 2>
					<cfset auxid = '00' & AVGR_ID>
				<cfelseif len(AVGR_ID) is 3>
					<cfset auxid = '0' & AVGR_ID>		
				</cfif>
				 <cfset AVGRDTINI = dateformat(AVGR_DT_INICIO,"DD/MM/YYYY")>
				 <cfset AVGRDTFIN = dateformat(AVGR_DT_FINAL,"DD/MM/YYYY")>
				 <cfset auxanoid = AVGR_ANO & '/' & auxid>
				<cfif len(AVGR_ANEXO) lte 0>
				<cfset habtn = 'disabled'>
				<cfelse>
				<cfset habtn = ''>					  
				</cfif>	
				<!--- <cfset auxcaminho = mid(AVGR_ANEXO, 36, len(AVGR_ANEXO))> --->
				 
				 <cfset auxst = AVGR_status>
				  <tr valign="middle" bgcolor="#scor#" class="exibir"><td bgcolor="#scor#"><div align="center">#auxanoid#</div></td>
				    <td bgcolor="#scor#">#AVGRDTINI#</td>
				    <td><div align="center">#AVGRDTFIN#</div></td>

					<td>#AVGR_TITULO#</td>
					<td>
					  <div align="center">
						
					    <button name="submitAlt" type="button" class="botao" onClick="visualizar('#AVGR_ANO#','#AVGR_ID#','vis');">
					    #auxanoid# </button>
		              </div></td>
			            <td><div align="center">
			              <input type="button" class="botao" name="Abrir" value="Abrir Anexo" onClick="window.open('abrir_pdf_act.cfm?arquivo=#AVGR_ANEXO#','_blank')" #habtn#>
			              </div></td>
			   </tr>
			  <input type="hidden" name="AVGRID" value="#AVGR_ID#">
		    </form>
			<cfif scor eq 'f7f7f7'>
		      <cfset scor = 'CCCCCC'>
			<cfelse>
		      <cfset scor = 'f7f7f7'>
			</cfif>
		</cfif> 			
 		  </cfoutput>
<!---	  </cfif> --->
<tr valign="baseline">
  <td colspan="6" class="titulos">&nbsp;</td>
</tr>
<tr valign="baseline">
            <td colspan="6" class="titulos">
                    
              <div align="center">
                <input name="Submit1" type="button" class="form" id="Submit1" value="FECHAR" onClick="window.close()">
                </div></td>
          </tr>
</table>

	<!--- FIM DA ÁREA DE CONTEÚDO --->

	</table>

 </form>   
<cfoutput>
<form name="formvolta" method="post" action="index.cfm?opcao=permissao15">
  <input name="sacao" type="hidden" id="sacao" value="voltar">
</form> 

<form name="formx" method="POST" action="Avisosgrupos_botao.cfm">
  <input name="frmx_ano" type="hidden" id="frmx_ano" value="">
  <input name="frmx_id" type="hidden" id="frmx_id" value="">
  <input name="frmx_sacao" type="hidden" id="frmx_sacao">
</form>
</cfoutput>
  <!--- Término da área de conteúdo --->
</body>
</html>

