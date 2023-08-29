<cfquery name="qUsuario" datasource="#dsn_inspecao#">
SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena 
FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfset auxdt = createodbcdate(CreateDate(year(now()),month(now()),day(now())))>

<cfquery name="rsAviso" datasource="#dsn_inspecao#">
SELECT AVGR_ANO, AVGR_ID, AVGR_TITULO, AVGR_DT_INICIO, AVGR_DT_FINAL, AVGR_GRUPOACESSO, AVGR_AVISO, AVGR_status, AVGR_ANEXO
FROM AvisosGrupos 
WHERE (AVGR_DT_INICIO<=#auxdt# AND AVGR_DT_FINAL>=#auxdt# AND AVGR_status='A') AND 
(AVGR_GRUPOACESSO ='#qUsuario.Usu_GrupoAcesso#' OR AVGR_GRUPOACESSO='GERAL' OR 
(AVGR_GRUPOACESSO='GESTORINSPETOR' AND ('#qUsuario.Usu_GrupoAcesso#'='GESTORES' Or '#qUsuario.Usu_GrupoAcesso#'='INSPETORES'))
OR (AVGR_GRUPOACESSO='GESTORINSPETORANALISTA' AND ('#qUsuario.Usu_GrupoAcesso#'='GESTORES' Or '#qUsuario.Usu_GrupoAcesso#'='INSPETORES' Or '#qUsuario.Usu_GrupoAcesso#'='ANALISTAS')))
ORDER BY AVGR_ID desc, AVGR_GRUPOACESSO, AVGR_DT_INICIO
</cfquery>

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<style type="text/css">
<!--
/* FORM */
.form {
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 10px;
	font-style: normal;
	color: #053C7E;
	text-decoration: none;
	background-color: #FFF;
	border: 1px solid #B7B7B7;
}
/* EXIBIR */
.texto_help {
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 12px;
	color: #053C7E;
	text-decoration: none;
}
.style1 {font-size: 9}
-->
</style>
<script language="JavaScript">
function sair(){
//alert('aqui');
   if (document.frmaviso.frmsair.value == 0) {
   window.close();
   }
  }
</script>
</head>
<!--- <cfif isDefined("botaosn")>
 <cfinclude template="cabecalho.cfm">
</cfif> --->
<!--- <cfoutput>rotina:#rotina#</cfoutput> --->
<body onLoad="sair()";>
<!--- Área de conteúdo   --->	
<form action="" method="get" target="" name="frmaviso">	 
      <table align="center">
 
        <tr>
          <td colspan="2" align="center" class="texto_help">AVISOS - SNCI </td>
        </tr>

		<cfset AVGRGRUPOACESSO = ''>
		<cfset numaviso = 1>
<cfoutput query="rsAviso">
    <cfif len(AVGR_ID) is 1>
	    <cfset auxid = '000' & AVGR_ID>
	<cfelseif len(AVGR_ID) is 2>
	    <cfset auxid = '00' & AVGR_ID>
	<cfelseif len(AVGR_ID) is 3>
	    <cfset auxid = '0' & AVGR_ID>		
	</cfif>
    <cfset ctrlaviso = 'Aviso nº ' & auxid & '/' & AVGR_ANO & ' - ' & AVGR_TITULO>
	<cfif len(AVGR_ANEXO) lte 0>
		<cfset habtn = 'disabled'>
	<cfelse>
		<cfset habtn = ''>					  
	</cfif>	
	<!--- <cfset auxcaminho = mid(AVGR_ANEXO, 36, len(AVGR_ANEXO))> --->
       <tr>
          <td width="720"><label class="texto_help"><strong>
             #ctrlaviso#   
          </strong></label></td>
		  <cfif habtn neq 'disabled'>
          <td width="196" bgcolor="##CCCCCC">
            <div align="center">
              <input type="button" class="form" name="Abrir" value="Abrir Anexo(#auxid#/#AVGR_ANO#)" onClick="window.open('abrir_pdf_act.cfm?arquivo=#AVGR_ANEXO#','_blank')" #habtn#>
            </div></td>
		 </cfif>
      </tr>
		<cfset AVGRGRUPOACESSO = rsAviso.AVGR_GRUPOACESSO>
<!--- </cfif>	 --->
<cfset auxmsg = 'Data Inicial: ' & DateFormat(rsAviso.AVGR_DT_INICIO,"DD/MM/YYYY") & '             Data Final: ' & DateFormat(rsAviso.AVGR_DT_FINAL,"DD/MM/YYYY")  & CHR(13) & CHR(13) & #rsAviso.AVGR_AVISO#>

        <tr>
          <td colspan="2"><label>
            <textarea name="frmaviso" cols="150" rows="18" class="texto_help" id="frmaviso">#rsAviso.AVGR_AVISO#</textarea>
          </label></td>
        </tr>
<cfset numaviso = numaviso + 1>		
<br>
</cfoutput>
        
        <tr>
          <td colspan="2">&nbsp;</td>
        </tr>
        <tr>
          <td colspan="2">
            
            <div align="center">
			  <input name="Submit1" type="button" class="form" id="Submit1" value="FECHAR" onClick="window.close()">
            </div></td>
        </tr>
    </table>  
	  <input name="frmsair" type="hidden" value="<cfoutput>#rsAviso.recordcount#</cfoutput>">
</form>
	
</body>
</html>
