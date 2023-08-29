<cfprocessingdirective pageEncoding ="utf-8"/>
 <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
   <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>  
	<!--- <cfoutput>#form.dr# #form.area_usu#</cfoutput> --->
	<cfquery name="qAcesso" datasource="#dsn_inspecao#">
		SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena
		FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
		WHERE Usu_DR = '#form.se#'
	</cfquery> 

<!---  --->
<cfif isDefined("Form.sacao") and #form.sacao# is 'exc'>
	<cfoutput>
		<cfset scont = 1>
		<cfset auxinic = 1>
		<cfset auxfim = 8>
		<cfloop condition="scont lte form.frmtotreg">
		  <cfset auxcodunid = mid(form.frmavaliar,auxinic,auxfim)>
		  <cfquery datasource="#dsn_inspecao#">
			DELETE 
			FROM Unidades
			WHERE Und_Codigo = '#auxcodunid#'		  
		  </cfquery>
		  <cfset auxinic = auxinic + 8> 
		  <cfset scont = scont + 1>
		</cfloop>
	</cfoutput> 
<cfset form.sacao = ''>	
</cfif>
<!---  --->

	<cfquery name="rsUnidade" datasource="#dsn_inspecao#">
		SELECT Und_Codigo, Und_Descricao, Und_CodDiretoria, TUN_Descricao, Und_NomeGerente
		FROM Unidades 
		LEFT JOIN Numera_Inspecao ON Und_Codigo = NIP_Unidade
		LEFT JOIN usuarios ON Und_Codigo = Usu_Lotacao
		INNER JOIN Tipo_Unidades ON Und_TipoUnidade = TUN_Codigo
		WHERE Und_CodDiretoria='#form.se#' AND 
		NIP_Unidade Is Null and 
		Usu_Lotacao is Null and 
		Und_Centraliza is null and
		Und_Ano_Avaliar is null
		order by Und_Descricao
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
//alert('linha53');
	var frm = document.forms[0];
	frm.frmavaliar.value = '';
	var totreg = frm.frmtotreg.value;
	frm.frmtotreg.value = 0;

	if (totreg == 1 && frm.cbavaliar.checked == true) {
		frm.frmavaliar.value = frm.frmavaliar.value + '' + frm.cbavaliar.value;
		frm.frmtotreg.value = 1;
	}

	for (x = 0 ; x <= totreg ; x++)	{
			if (frm.cbavaliar[x].checked == true) {
				frm.frmavaliar.value = frm.frmavaliar.value + '' + frm.cbavaliar[x].value;
				frm.frmtotreg.value++;
			}
	}
}
//=============================
function todos(){
//alert('linha 70');
	var frm = document.forms[0];
	var totreg = frm.frmtotreg.value;
	
	if (totreg == 1 && frm.cbtodos.checked == false) {frm.cbavaliar.checked = false; frm.confirma.disabled=true;} 
    if (totreg == 1 && frm.cbtodos.checked == true) {frm.cbavaliar.checked = true; frm.confirma.disabled=false;} 
	
	for (x = 0 ; x <= totreg ; x++)	{
	   if (frm.cbtodos.checked == true) {frm.cbavaliar[x].checked = true; frm.confirma.disabled=false;}
	   if (frm.cbtodos.checked == false) {frm.cbavaliar[x].checked = false; frm.confirma.disabled=true;}
	}
		
}

//=============================
function habbtn(a){
	var frm = document.forms[0];
	frm.confirma.disabled=true;
	var totreg = frm.frmtotreg.value;
	var auxtot = 0;
    
	if (totreg == 1 && frm.cbavaliar.checked == true) {frm.confirma.disabled=false;}
	
	for (x = 0 ; x <= totreg ; x++)	
	{
	   if (frm.cbavaliar[x].checked == true) 
	   {
	   auxtot = 1;
	   break
	   }
	}
	
   if (auxtot > 0) {frm.confirma.disabled=false;}
}
//--------------------------
function voltar(){
       document.formvolta.submit();
    }
</script>
<script language="JavaScript" src="../../mm_menu.js"></script>
	</head>

<body onLoad="onsubmit="mensagem()">


<cfinclude template="cabecalho.cfm">
	    <span class="exibir"><strong>
	    </strong></span>
        <table width="72%" border="0" align="center">
          <tr valign="baseline">
            <td colspan="6" class="exibir">&nbsp;</td>
          </tr>
          <tr valign="baseline">
            <td colspan="6" class="exibir"><div align="center"><span class="titulo2"><strong class="titulo1">EXCLUSÃO DE UNIDADES</strong></span></div></td>
          </tr>
          <tr valign="baseline">
            <td colspan="6">&nbsp;</td>
          </tr>
        </table>
<form action="Excluir_Unidades.cfm" method="post" target="_parent" name="form1"> 
	  <table width="91%" border="0" align="center">
 
        <!--- <cfif form.area_usu eq 'GESTORES' or form.area_usu eq 'INSPETORES' OR form.area_usu eq 'ANALISTAS' OR form.area_usu eq 'ORGAOSUBORDINADOR'> --->
        <tr bgcolor="f7f7f7">
          <td colspan="7" align="center" bgcolor="f7f7f7" class="titulo1">&nbsp;</td>
        </tr>

        <tr bgcolor="f7f7f7">
          <td colspan="7" align="center" bgcolor="#B4B4B4" class="titulo1">LISTAS DAS Unidades PASSÍVEIS DE EXCLUSÃO </td>
        </tr>

          <tr bgcolor="#CCCCCC">
            <td width="8%" align="center" class="titulos"><div align="left">Cód. Unidade </div></td>
            <td width="23%" align="center" class="titulos"><div align="left">Nome da Unidade </div></td>
            <td colspan="3" align="center" class="titulos"><div align="left">Selecionar todos(as)  
              <label>
              &nbsp;
              <input type="checkbox" name="cbtodos" onClick="todos()" value="cbtodos">
              </label>
            </div></td>
            <td width="18%" align="center" class="titulos"><div align="left">Descrição do Tipo </div></td>
            <td width="18%" align="center" class="titulos"><div align="left">Gestor(a) Unidade </div></td>
          </tr>
        <cfoutput query="rsUnidade">
		  	<cfset scor = 'f7f7f7'>		  
          	<tr>
            <td colspan="7" align="center" class="titulos">
			<table width="100%" align="center">
                <tr class="titulos" bgcolor="#scor#">
                  <td width="91">#Und_Codigo#</td>
                  <td width="359">#trim(Und_Descricao)#</td>
                  <td width="301">
                      <div align="left">
                        <input type="checkbox" name="cbavaliar" onClick="habbtn(this.checked)" value="#trim(Und_Codigo)#">
                      </div></td>
                  <td width="212">#TUN_Descricao#</td>
                  <td width="205">#Und_NomeGerente#</td>
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
          <td colspan="7" align="center" class="titulos"><hr></td>
        </tr>
        <tr>
          <td colspan="4" align="center"><button type="button" class="botao" onClick="voltar();">Voltar</button></td>
          <td colspan="3" align="center" class="titulo1"><button type="submit" class="botao" name="confirma" onClick="document.form1.sacao.value='exc';avaliar()" disabled="disabled">Confirmar Excluir </button></td>
        </tr>		

		<input name="frmavaliar" type="hidden" id="frmavaliar" value="">
		<input name="frmtotreg" type="hidden" id="frmtotreg" value="<cfoutput>#rsUnidade.recordcount#</cfoutput>">
		<input name="sacao" type="hidden" id="sacao" value="">
		<input name="se" type="hidden" id="se" value="<cfoutput>#form.se#</cfoutput>">
   </table>
</form>
<form name="formvolta" method="post" action="index.cfm?opcao=permissao0">
  <input name="sacao" type="hidden" id="sacao" value="voltar">
  <input name="se" type="hidden" value="<cfoutput>#form.se#</cfoutput>">
</form>
	  <!--- FIM DA ÁREA DE CONTEÚDO --->
   
  

  <!--- Término da área de conteúdo --->
</body>
</html>

