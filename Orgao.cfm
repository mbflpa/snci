<cfinclude template="verificar_logon.cfm">

<cfinvoke component="gerencias.gesit.sistemas.controledoc.cfc.Lote_Orgao" method="rsPessoal" returnvariable="request.qryPessoal">
</cfinvoke>

<cfinvoke component="gerencias.gesit.sistemas.controledoc.cfc.Lote_Orgao" method="rsOrgao" returnvariable="request.qryOrg">
</cfinvoke>

<html>
<head>
<title><cfoutput>#DR#</cfoutput></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<cfinclude template="css/estilo.css">
<script type="text/javascript">
<cfinclude template="mm_menu.js">
function troca(a,b,c,d,e,f,g,h,i,j,k){
//alert(a+b+c+d+e+f+g+h+i+j+k);
if (j == "usu") {
   alert("Sem permissão, procure sua SAD!");
   return false;
  }

if (a == "" || b == "" || c == "" || d == "" || e == "" || f == "" || g == "" || h == "" || i == "") {
   alert("Um ou mais campo(s) possui valor nulo!");
   return false;
    }
if (h.indexOf("@")<0){
   alert("Campo e-mail falta o caracter @ ");
   return false;
}
if (h.indexOf("correios")<0){
   alert("Campo e-mail falta texto correios");
   return false;
}
if (h.indexOf(".com.br")<0){
   alert("Campo e-mail falta .com.br");
   return false;
}	
if (k == "inc") 
   { l = "Inclusão?"; } 
else if (k == "alt") 
   { l = "Alteração?"; } 
else   
   { l = "Exclusão?"; }  
//c = c.toUpperCase(); 
if (confirm ("Deseja continuar processo de "+l)) 
   { 
    document.formx.sfrmnum.value=a;
    document.formx.sfrmsigla.value=b;
    document.formx.sfrmcont.value=c;
    document.formx.sfrmcateg.value=d;	
    document.formx.sfrmgestor.value=e;
    document.formx.sfrmtel.value=f;
    document.formx.sfrmender.value=g;
    document.formx.sfrmemail.value=h;
    document.formx.sfrmsubord.value=i;	
    document.formx.sacao.value=k;   
    document.formx.submit(); 
	} 
else 
{
   return false; 	
}
}
</script>
<style type="text/css">
<!--
.style1 {font-size: 10px}
-->
</style>
</head>
<body onLoad="foco()">
<script type="text/javascript">
    document.write("<table width='" + largura() + "' height='" + altura() + "' border='0'>");
 </script>
    <tr height="5%">
	  <td><div id="menu"><cfinclude template="menu.cfm"></div><hr></td>
	</tr>
<tr height="3%">
  <td align="center" valign="top" class="titulo"><div align="center">Cadastro de &Oacute;rg&atilde;os e Secções</div></td>
</tr>
<tr height="90%"><td valign="top" align="center">
<!--- Início da área de conteúdo --->
<form action="" method="POST" name="form1">
  <table width="83%" align="center" class="exibir">
    <tr valign="baseline">
      <td colspan="5" align="center" class="destaque"><hr></td>
      </tr>
    <tr valign="baseline" bgcolor="#BEC9DB">
      <td width="200" align="center" bgcolor="#BEC9DB" class="destaque"><div align="left">Sigla do setor </div>        
        <div align="left"></div></td>
      <td width="301" align="center" class="destaque"><div align="left">Contato(SAD)</div></td>
      <td width="161" align="center" class="destaque"><div align="left">Categoria 
          <label></label>
      </div> </td>
      <td width="211" align="center" class="destaque"><div align="left">Gestor(a)
          <label></label> 
	 </div>	  </td>
      <td width="87" align="center" class="destaque"><div align="left">Telefone</div></td>
    </tr>
    <tr valign="baseline">
      <td align="center" class="destaque"><div align="left">
          <input name="frmsigla" type="text" class="form" id="frmsigla" value="" size="27" maxlength="25" vazio="false" nome="Nome">
          <input name="frmsubord" type="hidden" id="frmsubord" value="<cfoutput>#org_usu#</cfoutput>">
          <input name="frmtpacesso" type="hidden" id="frmtpacesso" value="<cfoutput>#Acesso_Usu#</cfoutput>">
      </div></td>
      <td align="center" class="destaque"><div align="left">
        <input name="frmcont" type="text" class="form" id="frmcont" value="" size="27" maxlength="25" vazio="false" nome="Nome">
      </div></td>
      <td align="center" class="destaque"><div align="left">
        <select name="frmcateg" id="frmcateg">
          <option value="ADM">Administrativa</option>
          <option value="ASS">Assessoria</option>
          <option value="AC">Ag.Correios</option>
          <option value="CDD">CDD</option>
          <option value="REOP">Reop</option>
        </select>
      </div></td>
      <td align="center" class="destaque"><div align="left">
        <select name="frmgestor" id="frmgestor">
          <cfoutput query="request.qryPessoal">
		  <cfif Org_Subord is #Org_Usu_Sub#> 
            <option value="#pes_matricula#">#pes_nome#</option>
		  </cfif>	
          </cfoutput>
        </select>
      </div></td>
      <td align="center" class="destaque"><div align="left">
        <input name="frmtel" type="text" class="form" id="frmtel" value="" size="17" maxlength="15" vazio="false" nome="Nome">
      </div></td>
    </tr>
    <tr valign="baseline" bgcolor="#D4D0C8">
      <td colspan="2" align="center" bgcolor="#EDECE9" class="destaque"><div align="left">Endere&ccedil;o 
          <input name="frmender" type="text" class="form" id="frmender" value="" size="52" maxlength="50" vazio="false" nome="Nome">
          </div></td>
      <td colspan="3" align="center" bgcolor="#EDECE9" class="destaque"><div align="left">E-MAIL(SAD)
        <input name="frmemail" type="text" class="form" id="frmemail" value="@correios.com.br" size="52" maxlength="50" vazio="false" nome="Nome">
      </div></td>
    </tr>
    <tr valign="baseline">
      <td colspan="5" align="center" class="destaque"><div align="right">
        <button type="button" onClick="troca('0',frmsigla.value,frmcont.value,frmcateg.value,frmgestor.value,frmtel.value,frmender.value,frmemail.value,frmsubord.value,frmtpacesso.value,'inc');">Incluir &Oacute;rg&atilde;o </button>
      </div></td>
      </tr>
    </table>

</form>
<p><hr>
</p>
<table width="83%" border="0" align="center">
 
<cfoutput query="request.qryOrg">
<cfset ssubord = #Org_Subord#>
<cfset sgestor = #Org_Gestor#>
<cfif Org_Usu_Sub eq Org_Subord>
  
  <tr class="destaque"  bgcolor="BEC9DB">

    <td width="156" align="center"><div align="left">Sigla do setor </div></td>
    <td width="180" align="center"><div align="left">Contato(SAD)</div></td>
    <td width="159" align="center"><div align="left"><span class="texto">Categoria</span></div></td>
    <td width="154" align="center"><div align="left">Telefone</div></td>
    <td width="188" align=""><div align="left">Gestor(a)</div></td>
    <td colspan="4" align="center"><div align="center">Que fazer?</div></td>
    </tr>
<form method="Post" name="form2" action="">
 <input type="hidden" name="frmnum2" value="#Org_Num#">
<tr bgcolor="f7f7f7">

    <td class="texto"><input name="frmsigla2" type="text" class="form" id="frmsigla2" value="#Org_Sigla#" size="27" maxlength="25" vazio="false" nome="Nome">
	</td>
    <td class="texto"><input name="frmcont2" type="text" class="form" id="frmcont2" value="#Org_Contato#" size="27" maxlength="25" vazio="false" nome="Login"></td>
    <td class="texto">
	<select name="frmcateg2" id="frmcateg2">
      <option value="ADM" <cfif (isDefined("Org_Categ") AND "ADM" EQ #Org_Categ#)>selected="selected"</cfif>>Administrativa</option>
      <option value="ASS" <cfif (isDefined("Org_Categ") AND "ASS" EQ #Org_Categ#)>selected="selected"</cfif>>Assessoria</option>
      <option value="AC" <cfif (isDefined("Org_Categ") AND "AC" EQ #Org_Categ#)>selected="selected"</cfif>>Ag.Correios</option>
      <option value="CDD" <cfif (isDefined("Org_Categ") AND "CDD" EQ #Org_Categ#)>selected="selected"</cfif>>CDD</option>
      <option value="REOP" <cfif (isDefined("Org_Categ") AND "REOP" EQ #Org_Categ#)>selected="selected"</cfif>>Reop</option>
    </select>	</td>
    <td class="texto"><input name="frmtel2" type="text" class="form" id="frmtel2" value="#Org_Tel#" size="17" maxlength="15" vazio="false" nome="Senha"></td>
    <td class="texto"><label>
 	  <select name="frmgestor2" id="frmgestor2">
          <cfloop query="request.qryPessoal">
            <cfif Org_Subord eq #Org_Usu_Sub#>
              <option value="#Pes_Matricula#" <cfif (isDefined("sgestor") AND Pes_Matricula EQ sgestor)>selected="selected"</cfif>>#Pes_Nome#</option>
		    </cfif>
          </cfloop>
      </select>
    </label></td>
    <td width="74" rowspan="3" align="center" class="texto">
       <button type="button" name="submitAlt" onClick="troca(frmnum2.value,frmsigla2.value,frmcont2.value,frmcateg2.value,frmgestor2.value,frmtel2.value,frmender2.value,frmemail2.value,frmsubord2.value,frmtpacesso2.value,'alt');">Alterar</button>
	   </td>
	<td width="80" rowspan="3" align="center" class="texto"><button type="button" name="submitExc" onClick="troca(frmnum2.value,'0','0','0','0','0','0','a@correios.com.br','0',frmtpacesso2.value,'exc');">Excluir</button></td>
</tr>
<tr bgcolor="f7f7f7" class="destaque">
  <td class="texto">Subordinada &agrave; :</td>
  <td colspan="2" class="texto"><div align="left">Endere&ccedil;o</div>
    <div align="center"></div></td>
  <td colspan="2" class="texto">Email(SAD)</td>
  </tr>
<tr bgcolor="f7f7f7">
  <td class="texto"><select name="frmsubord2" id="frmsubord2">
    <cfloop query="request.qryOrg">
	
      <option value="#Org_Num#" <cfif (isDefined("ssubord") AND Org_Num EQ #ssubord#)>selected="selected"</cfif>>#Org_Sigla#</option>
    </cfloop>
  </select></td>
  <td colspan="2" class="texto"><input name="frmender2" type="text" class="form" id="frmender2" value="#Org_Ender#" size="52" maxlength="50" vazio="false" nome="Nome"></td>
  <td colspan="2" class="texto"><input name="frmemail2" type="text" class="form" id="frmemail2" value="#Org_Email#" size="52" maxlength="50" vazio="false" nome="Nome">
    <input name="frmtpacesso2" type="hidden" id="frmtpacesso2" value="#Acesso_Usu#"></td>
  </tr>
<tr bgcolor="f7f7f7">
  <td colspan="7" class="texto"><hr></td>
  </tr>
<tr bgcolor="f7f7f7">
  <td colspan="7" class="texto"><hr></td>
</tr>
</form> 
</cfif>
  </cfoutput>
</table>
<form name="formx" method="POST" action="CFC/Orgao.cfc?method=IncOrg">
  <input name="sfrmnum" type="hidden" id="sfrmnum"> 
  <input name="sfrmsigla" type="hidden" id="sfrmsigla">
  <input name="sfrmcont" type="hidden" id="sfrmcont">
  <input name="sfrmcateg" type="hidden" id="sfrmcateg">
  <input name="sfrmgestor" type="hidden" id="sfrmgestor">
  <input name="sfrmtel" type="hidden" id="sfrmtel">
  <input name="sfrmender" type="hidden" id="sfrmender">
  <input name="sfrmemail" type="hidden" id="sfrmemail">
  <input name="sfrmsubord" type="hidden" id="sfrmsubord">  
  <input name="sacao" type="hidden" id="sacao">
</form>
<!--- Término da área de conteúdo --->
	</td></tr>
	<tr>
	  <td height="2%" valign="bottom"><hr><div id="rodape"><cfinclude template="rodape.cfm"></div></td>
	</tr>
  </table>
</body>
</html>