<cfprocessingdirective pageEncoding ="utf-8"/> 
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>  

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_DR, Usu_GrupoAcesso, Usu_Matricula, Usu_Email, Usu_Apelido,Usu_Coordena from usuarios 
	where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfquery name="rsAno" datasource="#dsn_inspecao#">
SELECT Grp_Ano
FROM Grupos_Verificacao
where Grp_Ano <= year(getdate())
GROUP BY Grp_Ano
ORDER BY Grp_Ano DESC
</cfquery> 

<cfquery name="rsTipo" datasource="#dsn_inspecao#">
SELECT DISTINCT TUI_TipoUnid, TUN_Descricao, TUI_Modalidade
FROM Tipo_Unidades INNER JOIN TipoUnidade_ItemVerificacao ON TUN_Codigo = TUI_TipoUnid
where tui_Ano = year(getdate())
ORDER BY TUN_Descricao
</cfquery> 

<cfinclude template="cabecalho.cfm">
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<script language="javascript">
//========================
function valida_acao(a) {
//alert(a);
//return false;
var   grpacesso = '<cfoutput>#ucase(trim(qAcesso.Usu_GrupoAcesso))#</cfoutput>';
if (a=='S' && (grpacesso=='GESTORES' || grpacesso=='ANALISTAS' || grpacesso=='INSPETORES')){
alert('Atenção!\n\nPrezado usuário, o plano de testes analático é pra utilização restrita do controle interno.\n\nNão deverá ser divulgado/disponibilizado aos demais órgãos dos correios');
}
var frm = document.forms[0];
frm.frmacao.value=a;
//alert(document.frm1.frmacao.value);
//return false;
}

</script>
 <link href="css.css" rel="stylesheet" type="text/css">
 <style type="text/css">
<!--
.style2 {color: #fff}
-->
 </style>
</head>
<body>

<tr>
   <td colspan="6" align="center">&nbsp;</td>
</tr>

<!--- �rea de conte�do   --->
<form name="frm1" method="get" action="rel_itensverificacao.cfm" target="_blank">
  <table width="31%" align="center" bordercolor="#000000">
        <tr>
          <td colspan="5" align="center" class="titulo1"><strong>PLANO DE TESTES</strong></td>
        </tr>
        <tr>
          <td colspan="5" align="center">&nbsp;</td>
        </tr>
        <tr>
          <td colspan="5" align="center">&nbsp;</td>
        </tr>

        <tr class="exibir">
          <td width="1%">&nbsp;</td>
          <td colspan="4"><div align="left"><strong>
          Por Tipo Unidade e Ano </strong></div>            <div align="left"></div></td>
        </tr>

        <tr class="exibir">
          <td><strong>
            <div id="dDtInicio" class="exibir"></div>
          </strong></td>
          <td><strong> Tipo:</strong></td>
          <td colspan="4"><select name="frmtipo" class="form" id="frmtipo">
              <cfoutput query="rsTipo">
              <option value="#TUI_TipoUnid#">#TUN_Descricao#</option>
            </cfoutput>
          </select>          </td>
        </tr>
        <tr>
          <td></td>
          <td width="24%"></td>
          <td width="52%">      
          <td width="23%" colspan="3"
        ></td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td class="exibir"><strong>Ano:</strong></td>
          <td colspan="3" class="exibir">
		    <select name="frmtpano" class="form" id="frmtpano">
		  <cfif ucase(trim(qAcesso.Usu_GrupoAcesso)) neq 'INSPETORES'>
			 <cfoutput query="rsAno"> 
				  <option value="#Grp_Ano#">#Grp_Ano#</option>
			</cfoutput> 
		  <cfelse>
			<cfoutput>
		<!--- 	<option value="#rsAno.Grp_Ano#">#rsAno.Grp_Ano#</option>--->
			<option value="#year(now())#">#year(now())#</option>
			</cfoutput> 
		  </cfif>
            </select></td>
        </tr>
		
        <tr>
          <td><div align="center"></div></td>
          <td class="exibir"><div align="left"><strong>Modalidade:</strong>&nbsp;&nbsp;&nbsp;
                <cfquery name="rsModal" datasource="#dsn_inspecao#">
                SELECT distinct TUI_Modalidade  
                FROM TipoUnidade_ItemVerificacao 
                where tui_Ano = year(getdate())
                </cfquery>
          </div></td>
          <td colspan="2" class="exibir"><select name="frmmodal" class="form" id="frmmodal">
            <cfif ucase(trim(qAcesso.Usu_GrupoAcesso)) neq 'INSPETORES'>
              <option value="0">Presencial</option>
              <option value="1">A Dist&acirc;ncia</option>
              <option value="2">Mista</option>
              <cfelse>
              <cfoutput query="rsModal">
                <cfif rsModal.TUI_Modalidade is 0>
                  <cfset auxnome = 'Presencial'>
                  <cfelseif rsModal.TUI_Modalidade is 0>
                  <cfset auxnome = 'A Dist&acirc;ncia'>
                  <cfelse>
                  <cfset auxnome = 'Mista'>
                </cfif>
                <option value="#rsModal.TUI_Modalidade#">#auxnome#</option>
              </cfoutput>
            </cfif>
          </select>
          <label></label>          </td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td colspan="3">&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td colspan="3">
		  <table width="393" border="1">
		  <tr>
              <td colspan="4">
		  <table width="393">
            <tr>
              <td colspan="4"><div align="center"><img src="Figuras/print.png" width="46" height="44"></div></td>
            </tr>
            <tr>

              <td width="8"><div align="center"></div></td>
              <td width="199"><div align="center">
                <input name="como" type="submit" class="botao" id="como" value="Plano de Testes Analítico" onClick="valida_acao('S');">
              </div></td>
              <td width="6"><div align="center"><span class="exibir">
                <input name="frmacao" type="hidden" id="frmacao" size="1" maxlength="1">
              </span></div></td>
              <td width="160">
                
                <div align="center">
                  <input name="sem" type="submit" class="botao" id="sem" value="Plano de Testes Sintético" onClick="valida_acao('C')">
                </div></td>
            </tr>
          </table>
		  </td>
            </tr>
			</table>
		  </td>
        </tr>
      </table>
	</form>
</body>
</html>
