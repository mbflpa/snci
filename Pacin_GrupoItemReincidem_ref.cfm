<cfprocessingdirective pageEncoding ="utf-8"/>  
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
   <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>   

<cfif isDefined("form.acao") and form.acao eq 'buscargrpitm'>
    <cfquery name="rsgrpitm" datasource="#dsn_inspecao#">
        SELECT Itn_NumGrupo, Itn_NumItem
        FROM Itens_Verificacao
        WHERE (((Itn_Ano)='#form.frmano#') AND ((Itn_Modalidade)='#form.frmmodal#') AND ((Itn_TipoUnidade)=#form.frmtipounid#))
        ORDER BY Itn_NumGrupo, Itn_NumItem
    </cfquery>
<cfelse>
    <cfset form.frmtipounid=''>
</cfif>

<!---  --->
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
SELECT Usu_GrupoAcesso, Usu_DR, Usu_Coordena, Usu_Matricula FROM Usuarios WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfquery name="rsSE" datasource="#dsn_inspecao#">
	SELECT Dir_Codigo, Dir_Sigla
	FROM Diretoria
	WHERE Dir_Codigo <> '01'
</cfquery>
<cfquery name="rstpunid" datasource="#dsn_inspecao#">
	SELECT TUN_Codigo, TUN_Descricao
	FROM Tipo_Unidades
	ORDER BY TUN_Descricao
</cfquery>

<cfset auxanoatu = year(now())>
<cfquery name="rsAno" datasource="#dsn_inspecao#">
SELECT Andt_AnoExerc
FROM Andamento_Temp
GROUP BY Andt_AnoExerc
HAVING Andt_AnoExerc  < '#auxanoatu#'
ORDER BY Andt_AnoExerc DESC
</cfquery>
<!--- =========================== --->

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<script language="javascript">

function validarform() {
//alert('aqui....');
    var frm = document.forms[0];
	var messelec = frm.frmmes.value;
	var mesatual = frm.frmmesatual.value;
//alert(frm.frmUsuGrupoAcesso.value);
//alert(frm.frmdia.value);

	//alert('frmanoselecionado ' + frm.frmano.value + ' Ano atual ' + frm.frmanoatual.value + ' Mes selecionado ' + frm.frmmes.value + ' mes atual: ' + mesatual);	
	if (eval(frm.frmano.value) == eval(frm.frmanoatual.value))
	{
	if (eval(messelec) >= eval(mesatual)){
	alert('Gestor(a), o mês selecionado para o ano selecionado ainda não gerado!');
	return false;
	}

    if (eval(messelec) == eval(mesatual - 1) && frm.frmUsuGrupoAcesso.value != 'GESTORMASTER' && frm.frmdia.value <= 10){
	alert('Gestor(a), o mês selecionado para o ano selecionado ainda não gerado!');
	return false;
	}	
	} 


//return false;
}
</script>
 <link href="css.css" rel="stylesheet" type="text/css">
</head>
<br>
<body>

<!--- <cfinclude template="cabecalho.cfm"> --->
<tr>
   <td colspan="6" align="center">&nbsp;</td>
</tr>

<!--- area de conteudo   --->
	<form action="index.cfm?opcao=permissao27" method="post" target="" name="frmObjeto" onSubmit="return validarform()">
	  <table width="38%" align="center">
       
        <tr>
          <td colspan="5" align="center" class="titulo2">Registrar Reincindência para Grupo Item no PACIN</td>
        </tr>
        <br>
        <tr>
          <td colspan="5" align="center">&nbsp;</td>
        </tr>
        <tr>
          <td colspan="5" align="center"><div align="left"><strong class="titulos">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Filtro de sele&ccedil;&atilde;o:
            
          </strong></div></td>
        </tr>

        <tr>
          <td width="2%"></td>
          <td colspan="4"><strong>
          </strong><strong><span class="exibir">
          </span></strong></td>
        </tr>
        <cfset cont = year(now())>		  
        <tr>
            <td>&nbsp;</td>
            <td class="exibir"><strong>Exercício &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: </strong></td>
            <td colspan="2">
			<select name="frmano" class="exibir" id="frmano">
                <option value="<cfoutput>#year(now()) + 1#</cfoutput>"><cfoutput>#year(now()) + 1#</cfoutput></option>
              <cfloop condition="cont gte 2018">
                <option value="<cfoutput>#cont#</cfoutput>"><cfoutput>#cont#</cfoutput></option>
				<cfset cont = cont - 1>
              </cfloop>
            </select></td>
        </tr>
        <tr>
            <td>&nbsp;</td>
            <td width="39%" class="exibir"><strong>Modalidade&nbsp;&nbsp;: </strong></td>
            <td colspan="2">
                <select name="frmmodal" class="exibir" id="frmmodal">
                    <option value="0">Presencial</option>
                    <option value="1">A Distância</option>
                    <option value="2">Mista</option>
                </select>
            </td>
        </tr>        
        <tr>
            <td>&nbsp;</td>
            <td width="39%" class="exibir"><strong>Tipo de Unidade&nbsp;&nbsp;: </strong></td>
            <td colspan="2">
                <select name="frmtipounid" class="exibir" id="frmtipounid"  onChange="buscar(this.value)">
                    <option value="">---</option>
                    <cfoutput query="rstpunid">
                        <option value="#TUN_Codigo#" <cfif #TUN_Codigo# eq #form.frmtipounid#>selected</cfif>>#ucase(trim(TUN_Descricao))#</option>  
                    </cfoutput>
                </select>
            </td>
        </tr>
        <tr>
            <td>&nbsp;</td>
            <td width="39%" class="exibir"><strong>Grupo_Item&nbsp;&nbsp;: </strong></td>
            <td colspan="2">
                <select name="frmgrpitm" class="exibir" id="frmgrpitm">
                    <option value="">---</option>
                    <cfif isDefined("form.acao") and form.acao eq 'buscargrpitm'>
                        <cfoutput query="rsgrpitm"> 
                            <option value="#Itn_NumGrupo#_#Itn_NumItem#">#Itn_NumGrupo#_#Itn_NumItem#</option>  
                        </cfoutput>   
                    </cfif>
                </select>
            </td>
        </tr>  
        <tr>
          <td>&nbsp;</td>
          <br>
            <td colspan="3" align="right">
                <input name="Confirmar" type="submit" class="botao" id="Confirmar" value="Confirmar" disabled>
            </td>
        </tr>
        <tr>
            <td>&nbsp;</td>
            <td colspan="3">&nbsp;</td>
        </tr>

        <tr>
          <td>&nbsp;</td>
          <td colspan="3">&nbsp;</td>
        </tr>
      </table>
      <input type="hidden" id="acao" name="acao" value="">
	</form>
    <script>
      function buscar(a) {
        var frm = document.forms[0];
        frm.acao.value='buscargrpitm';
		frm.submit();
      }
    </script>
</body>
</html>
