	<cfprocessingdirective pageEncoding ="utf-8"/>
	<!--- <cfoutput>#form.dr# #form.area_usu#</cfoutput> --->
	<cfquery name="qAcesso" datasource="#dsn_inspecao#">
		SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena
		FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
		WHERE Usu_DR = '#form.dr#'
	</cfquery>
	<cfquery name="rsMigrar" datasource="#dsn_inspecao#">
		SELECT Und_Codigo, Und_Descricao, Und_Status
		FROM Unidades
		WHERE Und_Codigo Like '#form.dr#%' AND Und_Status = 'A'
	</cfquery>
	<cfquery name="rsGestar" datasource="#dsn_inspecao#">
		SELECT Dir_Codigo, Dir_Sigla
		FROM Diretoria
		WHERE Dir_Codigo <> '01'
	</cfquery>
    <cfset form.area_usu = trim(ucase(form.area_usu))>
<!--- 	<cfoutput>#form.area_usu#</cfoutput> --->
	<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>Sistema Nacional de Controle Interno</title>
	<link href="../../estilo.css" rel="stylesheet" type="text/css">
	<link href="css.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
// função que transmite as rotinas de alt, exc, etc...
function incluir(a,b,c,d,e,f){
//          a              b                 c             d     e
//dominio.value,matr_usu.value,apelido_usu.value,lotacao.value,'inc'
//          a         b                      c                 d                  e                    e                 e
//dominio.value,matr_usu.value,apelido_usu.value,lotacao_uni.value,lotacao_reop.value,lotacao_subreg.value,lotacao_ges.value,
//                h                 i                   j      k
//lotacao_depto.value,lotacao_ger.value,lotacao_super.value,'inc'

    c = c.toUpperCase();
	//alert(a + ' ' + b + ' ' + c + ' ' + d + ' ' + e + ' ' + f + ' ' + g + ' ' + h);
					
	if (a == "---" || b == "" || c == "" || d == "" || e == "---") {
	   alert("Um ou mais campo(s) sem selecionar dados!");
	   return false;
	}
    if (a == "CORREIOSNET" && b.length != 11) {
	   alert("Favor informar a Matrícula com 8 dígitos.");
	   return false;
	}
	if (a == "EXTRANET" && b.length != 14) {
	   alert("Favor informar o CPF com 11 dígitos.");
	   return false;
	}	

	if (e == "---") {
	   alert("Favor selecionar uma lotação desta ação!");
	   return false;
	}

	   document.formx.sdominio.value=a;
	   document.formx.smatr_usu.value=b;
	   document.formx.sapelido_usu.value=c;
	   document.formx.semail_usu.value=d;
	   document.formx.slotacao.value=e;
	   document.formx.sacao.value=f;
       document.formx.submit();  
	   
}
//=============================
function confirmemigrar(a,b,c){
//(document.formx.frmmigrarpara.value,document.formx.frmmigrar.value,'migrar'

//alert(a + b + c);
return false;					
	if (a == '---' || a == '') {
	   alert("Selecione uma opção no campo Migrar para:");
	   return false;
	}
	if (b == '') {
	   alert("Selecione um ou mais destinatário(s) na coluna Migrar para?");
	   return false;
	}

	  // document.formx.sdominio.value=a;
	  // document.formx.smatr_usu.value=b;
	  //document.formx.sapelido_usu.value=c;
	  // document.formx.slotacao.value=d;
	   document.formx.sacao.value=c;
       document.formx.submit();  
	   
}
//=============================
function excluir(a,b,c){
  //         a           b       c
  //    area.value,login.value,'exc'
//alert(a + b + c);
 	if (confirm ("Deseja Excluir?"))
	   {
  		document.formx.sarea_ga.value=a;
        document.formx.slogin.value=b;
		document.formx.sacao.value=c;
		document.formx.submit(); 
		}
	else
	   {
	   return false;
	   }
}
//=============================
function fazgestao(a){
	//alert(a);
	 
	var aux = document.formx.frmfazgestao.value;
    document.formx.frmfazgestao.value = '';
	if (aux == '') 
	   {
	   aux = a;
	   document.formx.frmfazgestao.value = aux;
	//   	   alert('linha114 ' + aux);
	   } 
	else 
	   {
	   if (aux == a) 
	   {
	   aux = '';
	   document.formx.frmfazgestao.value = aux;
	//   	alert('linha122 ' + aux);
	   } 
	   else 
	   {
	    var posic = aux.indexOf(a); 
		var tam = aux.length;
		//alert('posicao: ' + posic + ' tamanho: ' + tam);
	    if (posic < 0) 
	    {
		 aux = aux + a;
		 document.formx.frmfazgestao.value = aux;
	  // 	   alert('linha134 ' + aux);
		} 
		else 
		  {
		   if (posic == 0)
		   {
		    aux = aux.substring(2, tam);
			document.formx.frmfazgestao.value = aux;
	  //	   alert('linha142 ' + aux);
		   } 
		   else 
		     {
		      if ((posic + 1) == tam) 
			  {
			   aux = aux.substring(0, (posic - 1));
			   document.formx.frmfazgestao.value = aux;
			//   alert('linha150 ' + aux);
			  } 
			  else 
			      {
				    aux = aux.substring(0, (posic)) + aux.substring((posic + 2), tam);
					document.formx.frmfazgestao.value = aux;
		   	    //    alert('linha156 ' + aux);
				  }
				 // aux = '';
		     }
		  }
	   }
	 }
	
	//alert(aux);
    //alert('valor salvo: ' + document.formx.frmfazgestao.value);
}
//=============================
function migrar(a){
	//alert(a);
	//   if (vlr.length == 13) {vlre = vlr.substring(0, 2) + '.' + vlr.substring(2, 5) + '.' + vlr.substring(5, 8) + '.' + vlr.substring(8, 11) + ',' + vlr.substring(11, vlr.length)}
 
	var aux = document.formx.frmmigrar.value;
    document.formx.frmmigrar.value = '';
	if (aux == '') 
	   {
	//   alert('linha88');
	   aux = a;
	   document.formx.frmmigrar.value = aux;
	   } 
	else 
	   {
	   if (aux == a) 
	   {
	 //  alert('linha94');
	   aux = '';
	   document.formx.frmmigrar.value = aux;
	   } 
	   else 
	   {
	    var posic = aux.indexOf(a); 
		var tam = aux.length;
		//alert('posicao: ' + posic + ' tamanho: ' + tam);
	    if (posic < 0) 
	    {
		// alert('linha99');
		 aux = aux + a;
		 document.formx.frmmigrar.value = aux;
		} 
		else 
		  {
		   if (posic == 0)
		   {
		 //  alert('linha106');
		    aux = aux.substring(8, tam);
			document.formx.frmmigrar.value = aux;
		   } 
		   else 
		     {
		      if ((posic + 8) == tam) 
			  {
			//  alert('linha113');
			   aux = aux.substring(0, (posic - 1));
			   document.formx.frmmigrar.value = aux;
			  } 
			  else 
			      {
				//  alert('linha118');
				    aux = aux.substring(0, (posic - 1)) + aux.substring((posic + 7), tam);
					document.formx.frmmigrar.value = aux;
				  }
				 // aux = '';
		     }
		  }
	   }
	 }
	
	//alert(aux);
	

    //alert('valor salvo: ' + document.formx.frmmigrar.value);
}
//=============================
function mudarperfil(a,b,c){
//<button name="submitAlt" type="button" class="botao" onClick="mudarperfil('INSPETORES',login.value,'alt');">
  //         a           b       c
  //    area.value,login.value,'exc'
//alert(a + b + c);
 	if (confirm ("Confirma Alterar o Grupo de Acesso para: " + a + " ?"))
	   {
  		document.formx.sarea_ga.value=a;
        document.formx.slogin.value=b;
		document.formx.sacao.value=c;
		document.formx.submit(); 
		}
	else
	   {
	   return false;
	   }
}
//=============================
function mudarse(a,b,c){

//alert(a + b + c);
 	if (confirm ("Confirma Alterar o Valor da SE para: " + a + " ?"))
	   {
  		document.formx.soutros.value=a;
        document.formx.slogin.value=b;
		document.formx.sacao.value=c;
		document.formx.submit(); 
		}
	else
	   {
	   return false;
	   }
}
//=============================
function permitirgestar(a){

//alert(a);
    var auxopc = document.formx.frmfazgestao.value;
	if (auxopc == ''){
	alert('Favor selecionar um(a) ou mais SE(s) para Permissão de Gestão');
	return false;
	}
	if (document.formx.frmmigrar.value == ''){
	alert('Favor selecionar um ou mais usuário(s) na coluna Permitir Gestão');
	return false;
	}
 	if (confirm ("Permite fazer Gestão aos Usuários:  " + document.formx.frmmigrar.value + '\n\n para a(s) SE´s: ' + auxopc + " ?"))
	   {
        document.formx.slogin.value=a;
		document.formx.sacao.value='permitirgestar';
		document.formx.submit(); 
		}
	else
	   {
	   return false;
	   }
}
//==============================
	<!--//Validação de campos vazios em formulário -->
	function voltar(){
       document.formvolta.submit();
    }
//==========================================	
	function Mascara_Matricula(Matricula)
	{
		switch (Matricula.value.length)
		{
			case 1:
				Matricula.value += ".";
				break;
			case 5:
				Matricula.value += ".";
				break;
			case 9:
				Matricula.value += "-";
				break;
		}
	}
//=============================================
	function Mascara_cpf(cpf)
	{
		switch (cpf.value.length)
		{
			case 3:
				cpf.value += ".";
				break;
			case 7:
				cpf.value += ".";
				break;
			case 11:
				cpf.value += "-";
				break;
		}
	}
	//=================================
	function validacao(a) {
	    var auxdominio = document.form1.dominio.value; 
		
		// CONTA DE USUARIO INTERNO
		if (a == 'matr_usu' && auxdominio == 'CORREIOSNET'){
			auxtxt = document.form1.matr_usu.value;
			auxtxt = auxtxt.toUpperCase();
			var i;
			var text = '';
			for (i = 0; i < auxtxt.length; i++) {
			   if (auxtxt.charCodeAt(i) >= 48 && auxtxt.charCodeAt(i) <= 57) {
				  text = text + auxtxt.charAt(i);
				  if (text.length == 1) {text = text + '.';};
				  if (text.length == 5) {text = text + '.';};
				  if (text.length == 9) {text = text + '-';};
			   
			   };
			}
			document.form1.matr_usu.value = text;
			//alert(text);
		}
		
//=====================================================================================	
		// CONTA DE USUARIO EXTERNO
		if (a == 'matr_usu' && auxdominio == 'EXTRANET'){
			auxtxt = document.form1.matr_usu.value;
			auxtxt = auxtxt.toUpperCase();
			var i;
			var text = '';
			for (i = 0; i < auxtxt.length; i++) {
			   if (auxtxt.charCodeAt(i) >= 48 && auxtxt.charCodeAt(i) <= 57) {
				  text = text + auxtxt.charAt(i);
				  if (text.length == 3) {text = text + '.';};
				  if (text.length == 7) {text = text + '.';};
				  if (text.length == 11) {text = text + '-';};
			   
			   };
			}
			document.form1.matr_usu.value = text;
			//alert(text);
		}	
//=====================================================================================		
		if (a == 'apelido_usu'){
			auxtxt = document.form1.apelido_usu.value;
			auxtxt = auxtxt.toUpperCase();
			var i;
			var text = '';
			for (i = 0; i < auxtxt.length; i++) {
			   if ((auxtxt.charCodeAt(i) == 0) || (auxtxt.charCodeAt(i) >= 65 && auxtxt.charCodeAt(i) <= 90)) {
				  text = text + auxtxt.charAt(i);
			   } else {text = text + ' ';}
			   ;
			}
			document.form1.apelido_usu.value = text;
			//alert(text);
		}		
		if (a == 'email_usu'){
			auxtxt = document.form1.email_usu.value;
			auxtxt = auxtxt.toLowerCase();
			
			//alert(text);
		}	
	}
//permite digitaçao apenas de valores numéricos
function numericos() {
var tecla = window.event.keyCode;
//permite digitação das teclas numéricas (48 a 57, 96 a 105), Delete e Backspace (8 e 46), TAB (9) e ESC (27)
//if ((tecla != 8) && (tecla != 9) && (tecla != 27) && (tecla != 46)) {
	
	if ((tecla != 46) && ((tecla < 48) || (tecla > 57))) {
		//alert(tecla);
	//  if () {
		event.returnValue = false;
	 // }
	}
//}
}

//	========== final exibirdominio ========
//==== Exibir GrupoAcesso =======
//=================
function grupoacesso(){
//alert(document.form1.area_usu.value);
  document.form1.submit();
 } 
</script>
<script language="JavaScript" src="../../mm_menu.js"></script>
	</head>

	
	<!--- <body onLoad="grupoacesso('---')"; onsubmit="mensagem()"> --->
<body onLoad="onsubmit="mensagem()">
<!--- 		<cfif isDefined("Form.ssuper") And (#Form.ssuper# neq "")>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
 <cfinclude template="cabecalho.cfm">
</table>
</cfif> --->
	
    <cfinvoke component="SNCI.cfc.rotinas_permissoes" method="rsqArea" returnvariable="request.qArea">
	</cfinvoke>

    <cfinvoke component="SNCI.cfc.rotinas_permissoes" method="rsArea1" returnvariable="request.Area1">
			 <cfinvokeargument name="sSEprinci" value="#form.dr#">
			 <cfinvokeargument name="sSEsubord" value="#form.dr#">
	</cfinvoke>

	<cfinvoke component="SNCI.cfc.rotinas_permissoes" method="rsqArea2" returnvariable="request.qArea2">
			 <cfinvokeargument name="sSEprinci" value="#form.dr#">
			 <cfinvokeargument name="sSEsubord" value="#form.dr#">
    </cfinvoke>
	<cfinvoke component="SNCI.cfc.rotinas_permissoes" method="rsqArea3" returnvariable="request.qArea3">
			 <cfinvokeargument name="sSEprinci" value="#form.dr#">
			 <cfinvokeargument name="sSEsubord" value="#form.dr#">
    </cfinvoke>
	<cfinvoke component="SNCI.cfc.rotinas_permissoes" method="rsqSE" returnvariable="request.qSE">
			 <cfinvokeargument name="sSEprinci" value="#form.dr#">
			 <cfinvokeargument name="sSEsubord" value="#form.dr#">
    </cfinvoke>

	<cfinvoke component="SNCI.cfc.rotinas_permissoes" method="rsqCS" returnvariable="request.qCS">
	</cfinvoke>

	<cfinvoke component="SNCI.cfc.rotinas_permissoes" method="rsqReop" returnvariable="request.qReop">
			 <cfinvokeargument name="sSEprinci" value="#form.dr#">
			 <cfinvokeargument name="sSEsubord" value="#form.dr#">
	</cfinvoke>

	<cfinvoke component="SNCI.cfc.rotinas_permissoes" method="rsqUnidade" returnvariable="request.qUnidade">
			 <cfinvokeargument name="sSEprinci" value="#form.dr#">
			 <cfinvokeargument name="sSEsubord" value="#form.dr#">
	</cfinvoke>
	<cfinvoke component="SNCI.cfc.rotinas_permissoes" method="rsgov" returnvariable="request.qGov3">
<!--- 			 <cfinvokeargument name="sSEprinci" value="#form.dr#">
			 <cfinvokeargument name="sSEsubord" value="#form.dr#"> --->
	</cfinvoke>	
	
<cfinclude template="cabecalho.cfm">
<form name="form1" method="post" action="adicionar_permissao_rotinas_inspecao1.cfm">  

	    <span class="exibir"><strong>
	    </strong></span>
        <table width="80%" border="0" align="center">
          <tr valign="baseline">
            <td colspan="6" class="exibir"><div align="center"><span class="titulo1"><strong>Permiss&Otilde;es</strong></span></div></td>
          </tr>
          <tr valign="baseline">
            <td colspan="6"><span class="titulos">Superintendência:</span></td>
          </tr>
          <cfoutput>
            <tr valign="baseline">
              <td colspan="6"><select name="dr" id="dr" class="form" disabled>
                  <cfif qAcesso.Usu_DR eq '04'>
                    <option value="04" <cfif #trim(form.dr)# is '04'>selected</cfif>>#trim(qAcesso.Dir_Sigla)#</option>
                    <option value="70" <cfif #trim(form.dr)# is '70'>selected</cfif>>#trim(qAcesso.Dir_Sigla)#</option>
                    <cfset seprinc= '04'>
                    <cfset sesubor= '70'>
                    <cfelseif qAcesso.Usu_DR eq '10'>
                    <option value="10" <cfif #trim(form.dr)# is '10'>selected</cfif>>#trim(qAcesso.Dir_Sigla)#</option>
                    <option value="16" <cfif #trim(form.dr)# is '16'>selected</cfif>>#trim(qAcesso.Dir_Sigla)#</option>
                    <cfset seprinc= '10'>
                    <cfset sesubor= '16'>
                    <cfelseif qAcesso.Usu_DR eq '06'>
                    <option value="06" <cfif #trim(form.dr)# is '06'>selected</cfif>>#trim(qAcesso.Dir_Sigla)#</option>
                    <option value="65" <cfif #trim(form.dr)# is '65'>selected</cfif>>#trim(qAcesso.Dir_Sigla)#</option>
                    <cfset seprinc= '06'>
                    <cfset sesubor= '65'>
                    <cfelseif qAcesso.Usu_DR eq '26'>
                    <option value="26" <cfif #trim(form.dr)# is '26'>selected</cfif>>#trim(qAcesso.Dir_Sigla)#</option>
                    <option value="03" <cfif #trim(form.dr)# is '03'>selected</cfif>>#trim(qAcesso.Dir_Sigla)#</option>
                    <cfset seprinc= '26'>
                    <cfset sesubor= '03'>
                    <cfelseif qAcesso.Usu_DR eq '28'>
                    <option value="28" <cfif #trim(form.dr)# is '28'>selected</cfif>>#trim(qAcesso.Dir_Sigla)#</option>
                    <option value="05" <cfif #trim(form.dr)# is '05'>selected</cfif>>#trim(qAcesso.Dir_Sigla)#</option>
                    <cfset seprinc= '28'>
                    <cfset sesubor= '05'>
                    <cfelse>
                    <cfoutput>
                      <option selected="selected" value="#qAcesso.Usu_DR#">#qAcesso.Dir_Sigla#</option>
                    </cfoutput>
                  </cfif>
                </select>
              </td>
            </tr>
          </cfoutput>
          <tr valign="baseline">
            <td colspan="6"><span class="titulos">Grupo de Acesso:</span></td>
          </tr>
          <tr valign="baseline">
            <td width="17%"><select name="area_usu" id="area_usu" class="form" disabled>
                <cfoutput query="request.qArea">
                  <option <cfif trim(#UCase(form.area_usu)#) eq #UCase(Usu_GrupoAcesso)#> selected</cfif> value="#UCase(Usu_GrupoAcesso)#">#UCase(Usu_GrupoAcesso)#</option>
                </cfoutput>
              </select>
            </td>
            <td colspan="5">&nbsp;</td>
          </tr>
          <tr valign="baseline">
            <td colspan="6"><hr></td>
          </tr>
          <tr valign="baseline">
            <td colspan="6"><span class="titulos">Domínio:</span></td>
          </tr>
          <cfoutput>
            <tr valign="baseline">
              <td colspan="6"><select name="dominio" id="dominio" class="form"" onChange="(matr_usu.value='')">
               <!---    <option value="---">---</option> --->
                  <option value="CORREIOSNET">CORREIOSNET</option>
                  <option value="EXTRANET">EXTRANET</option>
              </select></td>
            </tr>
            <tr valign="baseline">
              <td colspan="6"><span class="titulos">Matr&iacute;cula/CPF:</span></td>
            </tr>
            <tr valign="baseline">
              <td colspan="6"><input type="text" name="matr_usu" id="matr_usu" class="form" maxlength="14" onBlur="validacao('matr_usu')" onKeyPress="if(dominio.value == 'CORREIOSNET'){Mascara_Matricula(this)}else if (dominio.value == 'EXTRANET'){Mascara_cpf(this)} else {dominio.focus()}; numericos()">
            </tr>
            <tr valign="baseline">
              <td colspan="6"><span class="titulos">Nome:</span></td>
            </tr>
            <tr valign="baseline">
              <td colspan="6"><input name="apelido_usu" type="text" class="form" id="apelido_usu" size="52" maxlength="50" onBlur="validacao('apelido_usu')" onKeyPress="if(dominio.value == '---'){dominio.focus()}">                  </td>
            </tr>
			<tr valign="baseline">
				<td colspan="6"><span class="titulos">Email:</span></td>
			  </tr>
			<tr valign="baseline">
				<td colspan="6"><input name="email_usu" type="text" class="form" id="email_usu" size="52" maxlength="50" onBlur="validacao('email_usu')" onKeyPress="if(dominio.value == '---'){dominio.focus()}">                  </td>
			  </tr>
		  
		  <cfquery name="qPermissoes" datasource="#dsn_inspecao#">
           SELECT Usu_DR, Usu_GrupoAcesso, Usu_Lotacao, Usu_Matricula, Usu_Login, Usu_Apelido, Usu_Email, Usu_LotacaoNome, Usu_Coordena 
           FROM Usuarios 
		   WHERE Usu_DR = '#form.dr#' AND Usu_GrupoAcesso = '#form.area_usu#' 
		   ORDER BY Usu_GrupoAcesso, Usu_LotacaoNome, Usu_Apelido
          </cfquery>
		  <cfif (trim(form.frmgrpacessologin) eq 'COORDENADOR')>
			<cfquery name="qCDR" datasource="#dsn_inspecao#">
				SELECT Cdr_DR, Dir_Sigla 
				FROM Coordenador INNER JOIN Diretoria ON Cdr_DR = Dir_Codigo 
				WHERE Cdr_Login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
			</cfquery>
		  </cfif>
		  </cfoutput>
		  
          <!--- ÁREA DE CONTEÚDO --->
          <tr valign="baseline">
            <td colspan="6">&nbsp;</td>
          </tr>
          <tr valign="baseline">
            <td height="19" colspan="6"><span class="titulos">Lota&ccedil;&atilde;o:</span></td>
          </tr>
          <tr valign="baseline">
            <cfif form.area_usu eq "UNIDADES">
              <td colspan="2"><div id="unida"><strong><span class="titulos">Unidade</span></strong></div></td>
              <td width="77%"><div id="unidb"><span class="exibir"><strong>
                  <select name="lotacao" class="form">
                    <option selected="selected" value="---">---</option>
                    <cfoutput query="request.qUnidade">
                      <option value="#und_Codigo#">#und_Descricao#</option>
                    </cfoutput>
                  </select>
              </strong></span></div></td>
              <br>
              <cfelseif form.area_usu eq "ORGAOSUBORDINADOR">
              <td colspan="2"><div id="orgsuba"><strong><span class="titulos">Órgão Subordinador</span></strong></div></td>
              <td width="77%"><div id="orgsubb"><span class="exibir"><strong>
                  <select name="lotacao" class="form">
                    <option selected="selected" value="---">---</option>
                    <cfoutput query="request.qReop">
					      <option value="#Rep_Codigo#">#Rep_Nome#(#Rep_Sigla#)</option>
                    </cfoutput>
                  </select>
              </strong></span></div></td>
              <br>
              <cfelseif form.area_usu eq "SUBORDINADORREGIONAL">
              <cfquery name="rsSUBREG" datasource="#dsn_inspecao#">
      SELECT Ars_Codigo, Ars_Descricao, Ars_Sigla FROM Areas WHERE Ars_Status = 'A' and Ars_GrupoAcesso = 'SUBREG' AND (LEFT(Ars_Codigo,2) = '#form.dr#' OR LEFT(Ars_Codigo,2) = '#form.dr#') ORDER BY Ars_Descricao
              </cfquery>
              <td colspan="2"><div id="subrega"><strong><span class="titulos">Subordinador Regional</span></strong></div></td>
              <td><div id="subregb"><span class="exibir"><strong><strong>
                  <select name="lotacao" class="form">
                    <option selected="selected" value="---">---</option>
                    <cfoutput query="rsSUBREG">
                      <option value="#Ars_Codigo#">#Ars_Descricao# (#Ars_Sigla#)</option>
                    </cfoutput>
                  </select>
              </strong></strong></span></div></td>
              <cfelseif (form.area_usu eq "DESENVOLVEDORES" OR form.area_usu eq "GESTORES" OR form.area_usu eq "INSPETORES" or form.area_usu eq "ANALISTAS")>
              <td colspan="2"><div id="areaa"><strong><span class="titulos">Área</span></strong></div></td>
              <td><div id="areab"><span class="exibir"><strong><strong>
                  <select name="lotacao" class="form">
                    <option selected="selected" value="---">---</option>
                    <cfoutput query="request.qArea2">
					 <cfif find("GCOP", trim(Ars_Sigla)) neq 0 or find("GCIA", trim(Ars_Sigla)) neq 0>
                      <option value="#Ars_Codigo#">#Ars_Descricao#(#Ars_Sigla#)</option>
					  </cfif>
                    </cfoutput>
                  </select>
              </strong></strong></span></div></td>
			  <cfelseif form.area_usu eq "GESTORMASTER" OR form.area_usu eq "GOVERNANCA">
              <td colspan="2"><div id="areaa"><strong><span class="titulos">Área</span></strong></div></td>
              <td><div id="areab"><span class="exibir"><strong><strong>
                  <select name="lotacao" class="form">
                    <option selected="selected" value="---">---</option>
                    <cfoutput query="request.qCS">
				         <option value="#Ars_Codigo#">#Ars_Descricao#(#Ars_Sigla#)</option>
	                </cfoutput>
                  </select>
              </strong></strong></span></div></td>
              <cfelseif  (form.area_usu eq "DEPARTAMENTO")>
              <td colspan="2"><div id="depa"><strong><span class="titulos">Departamento</span></strong></div></td>
              <cfquery name="rsDepto" datasource="#dsn_inspecao#">
      SELECT Dep_Codigo, Dep_Descricao FROM Departamento WHERE Dep_Status = 'A' and (LEFT(Dep_Codigo,2) = '#form.dr#' OR LEFT(Dep_Codigo,2) = '#form.dr#') ORDER BY Dep_Descricao
              </cfquery>
              <td><div id="depb"><span class="exibir"><strong><strong><strong><strong>
                  <select name="lotacao" class="form">
                    <option selected="selected" value="---">---</option>
                    <cfoutput query="rsDepto">
                      <option value="#Dep_Codigo#">#Dep_Descricao#</option>
                    </cfoutput>
                  </select>
              </strong></strong></strong></strong></span></div></td>
              <cfelseif form.area_usu eq "GERENTES">
              <cfquery name="rsGer" datasource="#dsn_inspecao#">
      SELECT Ars_Codigo, Ars_Descricao, Ars_Sigla FROM Areas WHERE Ars_Status = 'A' and Ars_GrupoAcesso = 'GERENTES' AND (LEFT(Ars_Codigo,2) = '#form.dr#' OR LEFT(Ars_Codigo,2) = '#form.dr#') ORDER BY Ars_Descricao
              </cfquery>
              <td colspan="2"><div id="gera"><strong><span class="titulos">Gerente</span></strong></div></td>
              <td><div id="gerb"><span class="exibir"><strong><strong><strong><strong>
                  <select name="lotacao" class="form">
                    <option selected="selected" value="---">---</option>
                    <cfoutput query="rsGer">
                      <option value="#Ars_Codigo#">#Ars_Descricao# (#Ars_Sigla#)</option>
                    </cfoutput>
                  </select>
              </strong></strong></strong></strong></span></div></td>
              <cfelseif form.area_usu eq "SUPERINTENDENTE">
              <cfquery name="rsSuper" datasource="#dsn_inspecao#">
      SELECT Dir_Sto, Dir_Descricao FROM Diretoria WHERE Dir_Status = 'A' and (Dir_Codigo = '#form.dr#' or Dir_Sto = '#form.dr#')
              </cfquery>
              <td colspan="2"><div id="supa"><strong><span class="titulos">Superintend&ecirc;ncia</span></strong></div></td>
              <td width="77%"><div id="supb"><span class="exibir"><strong>
                  <select name="lotacao" class="form">
                    <option selected="selected" value="---">---</option>
                    <cfoutput query="rsSuper">
                      <option value="#Dir_Sto#">#Dir_Descricao#</option>
                    </cfoutput>
                  </select>
              </strong> </span></div></td>
            </cfif>
          </tr>
          <tr valign="baseline">
            <td colspan="6">&nbsp;</td>
          </tr>
          <tr valign="baseline">
            <td colspan="6"><hr></td>
          </tr>
          <tr valign="baseline">
            <td colspan="6"><table width="100%" height="19" border="0">
                <tr>
                  <td><div align="right">
                    <button type="button" class="botao" onClick="voltar();">Voltar</button>
                  </div></td>
                  <td><div align="center">
                      <button type="button" class="botao" onClick="incluir(dominio.value,matr_usu.value,apelido_usu.value, email_usu.value, lotacao.value,'inc')"> Confirmar Permissão</button>
                  </div></td>
                </tr>
            </table></td>
          </tr>
          <tr valign="baseline">
            <td colspan="6"><hr></td>
          </tr>
        </table>
</form>
	  <table width="91%" border="0" align="center">
<cfif form.area_usu eq 'GESTORES' or form.area_usu eq 'INSPETORES' OR form.area_usu eq 'ANALISTAS' OR form.area_usu eq 'ORGAOSUBORDINADOR'>
	  <tr bgcolor="f7f7f7">
	    <td colspan="8" align="center" bgcolor="#B4B4B4" class="titulos">Permiss&atilde;o de Gest&atilde;o nas   SE(s)</td>
    </tr>
	  <tr bgcolor="f7f7f7">
	    <td colspan="8" align="center" class="titulos"><table width="95%" border="0">
		<tr>
		  <cfoutput query="rsGestar">
            <td><div align="center"><span class="exibir">#trim(rsGestar.Dir_Codigo)#</span></div></td>
		  </cfoutput>
          </tr>
		  	<tr>
		  <cfoutput query="rsGestar">
            <td><div align="center"><span class="exibir">#rsGestar.Dir_Sigla#</span></div></td>
		  </cfoutput>
          </tr>
          <tr>
		  <cfoutput query="rsGestar">
            <td width="854"><div align="center">
              <input type="checkbox" name="cbmigrar" value="#trim(rsGestar.Dir_Codigo)#" onClick="fazgestao(this.value)">
            </div></td>
		  </cfoutput>
          </tr>

        </table></td>
    </tr>
	  <tr bgcolor="f7f7f7">
	    <td colspan="8" align="center" class="titulos"><hr></td>
    </tr>
	  <tr>
	    <td colspan="8" align="center" class="titulos"> <button name="submitAlt" type="button" class="botao" onClick="permitirgestar('a');">Confirmar Permitir Gest&atilde;o </button></td>
    </tr>
	  <tr>
	    <td colspan="8" align="center" class="titulos"><hr></td>
    </tr>
</cfif>		
	  <tr bgcolor="f7f7f7">
	     <td colspan="7" align="center" bgcolor="#B4B4B4" class="titulos">Permiss&otilde;es concedidas</td>
		 
		 <cfset sarquivo = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #right(CGI.REMOTE_USER,8)# & '.xls'>
         <td align="center" bgcolor="#B4B4B4" class="titulos"><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img src="icones/excel.jpg" width="50" height="35" border="0"></a></td>
	  </tr>
	  <tr class="titulosClaro">
	    <td colspan="14" bgcolor="eeeeee" class="exibir"><cfoutput>Qtd. #form.area_usu#: #qPermissoes.recordCount#</cfoutput></td>
    </tr>
	    <tr bgcolor="#B4B4B4" class="exibir" align="center">
	  	<td width="11%"><div align="left">GRUPO DE ACESSO</div></td>
		<td width="17%"><div align="left">LOTA&Ccedil;&Atilde;O</div></td>
		<td width="7%">MATRICULA</td>
		<td width="16%" bgcolor="#B4B4B4"><div align="left">NOME</div></td>
		<td><div align="left">LOGIN</div></td>
		<td>FAZ GESTÃO</td>
		<td width="7%">
		<cfif ((form.frmgrpacessologin eq 'GESTORMASTER') or (form.frmgrpacessologin eq 'GESTORES') or (form.frmgrpacessologin eq 'ANALISTAS') or (trim(form.area_usu) eq 'INSPETORES'))>
		MUDAR GRUPO PARA 
		</cfif>
		</td>
		<td width="8%">
		<cfif ((form.frmgrpacessologin eq 'GESTORMASTER') or (form.frmgrpacessologin eq 'GESTORES') or (form.frmgrpacessologin eq 'ANALISTAS') or (trim(form.area_usu) eq 'INSPETORES'))>
		 ALTERAR(SE)
		</cfif>
		</td>
		<td>Linha</td> 
		<td width="8%">
		<cfif form.area_usu eq 'GESTORES' or form.area_usu eq 'INSPETORES' OR form.area_usu eq 'ANALISTAS'>
        Permitir Gestão
		</cfif>
		</td>
	    </tr>

	  <cfif qPermissoes.recordcount neq 0>
	  <cfquery name="rsXLS" datasource="#dsn_inspecao#">
		  SELECT case when left(Usu_Login,8) = 'EXTRANET' then concat(left(Usu_Login,9),'***',substring(trim(Usu_Login),12,8)) else concat(left(trim(Usu_Login),12),substring(trim(Usu_Login),13,4),'***',right(trim(Usu_Login),1)) end as UsuLogin, case when len(trim(Usu_Matricula)) > 8 then concat ('***.',substring(trim(Usu_Matricula),4,3),'.',substring(trim(Usu_Matricula),7,3),'-',right(trim(Usu_Matricula),2)) else concat (left(Usu_Matricula,1),'.',substring(trim(Usu_Matricula),2,3),'.***-',right(trim(Usu_Matricula),1)) end as UsuMatricula, Usu_Apelido, Usu_GrupoAcesso, Usu_DR, Usu_Lotacao, Usu_LotacaoNome, concat(left(Usu_Username,12),substring(Usu_Username,13,4),'***',right(Usu_Username,1)) as UsuUsername, convert(char,Usu_DtUltAtu,103) as UsuDtUltAtu
		  FROM Usuarios 
		  WHERE Usu_DR = '#form.dr#' AND Usu_GrupoAcesso = '#form.area_usu#'
		  ORDER BY  Usu_GrupoAcesso, Usu_Lotacao, Usu_Apelido
      </cfquery>
		<!--- Excluir arquivos anteriores ao dia atual --->
<!--- limpar .XLS --->
		<cfset sdtatual = dateformat(now(),"YYYYMMDDHH")>
		<cfset sdtarquivo = dateformat(now(),"YYYYMMDDHH")>
		<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
		<cfset slocal = #diretorio# & 'Fechamento\'>  
		
		<cfdirectory name="qList" filter="*.*" sort="name asc" directory="#slocal#">
		<cfoutput query="qList">
		   <cfset sdtarquivo = dateformat(dateLastModified,"YYYYMMDDHH")> 
			   <cfif left(sdtatual,8) eq left(sdtarquivo,8)>
					<cfif (right(sdtatual,2) - right(sdtarquivo,2)) gte 2>
					   <cffile action="delete" file="#slocal##name#">  
					</cfif>
			  <cfelseif left(sdtatual,8) gt left(sdtarquivo,8)>
				<cffile action="delete" file="#slocal##name#">
			  </cfif>
		<!--- 	 data atual: #sdtatual# -     Data do arquivo: #sdtarquivo#   nome do arquivo: #name#<br> --->
		</cfoutput>


			<!--- fim exclusão --->

			<cftry>
			
			<cfif Month(Now()) eq 1>
			  <cfset vANO = Year(Now()) - 1>
			<cfelse>
			  <cfset vANO = Year(Now())>
			</cfif>
			
			<cfset objPOI = CreateObject(
				"component",
				"Excel"
				).Init()
				/>
			
			<cfset data = now() - 1>
				 <cfset objPOI.WriteSingleExcel(
				FilePath = ExpandPath( "./Fechamento/" & sarquivo ),
				Query = rsXLS,
				ColumnList = "UsuLogin,UsuMatricula,Usu_Apelido,Usu_GrupoAcesso,Usu_DR,Usu_Lotacao,Usu_LotacaoNome,UsuUsername,UsuDtUltAtu",
				ColumnNames = "LOGIN,MATRICULA,NOME USUARIO,GRUPO ACESSO,SE,COD_LOTACAO,NOME DA LOTACAO,REALIZADO POR,DT REALIZACAO",
				SheetName = "PERMISSAO_SNCI"
				) />
			
			<cfcatch type="any">
				<cfdump var="#cfcatch#">
			</cfcatch>
			</cftry>	  
	      <cfset scor = 'f7f7f7'>
		<!---  <cfoutput>GRUPO ESCOLHIDO:#form.frmgrpacessologin#   COORDENA(sn): #form.frmcoordena#    SE do Logado: #form.frmse#   areadestino: #form.area_usu#</cfoutput> ---> 
		  <cfoutput query="qPermissoes">
 		     <form action="" method="POST" name="formexc">
				 <cfset cpf = trim(Usu_Matricula)>
				 <cfset mat = trim(Usu_Matricula)>
<!--- 				  <cfset matricula = Left(mat,1) & '.' & Mid(mat,2,3) & '.' & Mid(mat,5,3) & '-' &  Mid(mat,8,1)>
				  <cfset vCPF = Left(cpf,3) & '.' & Mid(cpf,4,3) & '.' & Mid(cpf,7,3) & '-' &  Mid(cpf,10,2)> --->
				  <tr valign="middle" bgcolor="#scor#" class="exibir"><td bgcolor="#scor#">#Usu_GrupoAcesso#</td>
				  <td>#Usu_LotacaoNome#</td>
					<cfif Left(Usu_login,11) eq 'CORREIOSNET'>
					  <cfset maskmatrusu = mat>
					  <cfset maskmatrusu = left(maskmatrusu,1) & '.' &  mid(maskmatrusu,2,3) & '.***-' & right(maskmatrusu,1)>
					  <cfset Usulogin = trim(Usu_login)>
					  <cfset Usulogin = left(Usulogin,12) & mid(Usulogin,13,4) & '***' & right(Usulogin,1)>
					<cfelse>
					  <cfset maskmatrusu = cpf>
					  <cfset maskmatrusu = '***.' &  mid(maskmatrusu,4,3) & '.' & mid(maskmatrusu,7,3) & '-' & right(maskmatrusu,2)>	
					  <cfset Usulogin = trim(Usu_login)>
					  <cfset Usulogin = left(Usulogin,9) & '***' &  mid(Usulogin,13,8)>				  
					</cfif>
					<td><div align="center">#maskmatrusu#</div></td>
					<td>#Usu_Apelido#</td>
<!--- 					<cfset Usulogin = trim(Usu_login)>
					<cfset Usulogin = left(Usulogin,12) & mid(Usulogin,13,4) & '***' & right(Usulogin,1)> --->
					<td width="5%">#Usulogin#</td>
					
						<td width="5%">#Usu_Coordena#</td>
						<td width="7%">
						<cfif (form.frmgrpacessologin eq 'GESTORMASTER' or (form.frmgrpacessologin eq 'GESTORES' AND len(form.frmcoordena) gt 0) or (form.frmgrpacessologin eq 'ANALISTAS' AND len(form.frmcoordena) gt 0)) and (trim(form.area_usu) eq 'INSPETORES')> 
						<!--- <td width="7%"> --->
						<button name="submitAlt" type="button" class="botao" onClick="mudarperfil('ANALISTAS',login.value,'altgrp');">
						  <div align="center">ANALISTAS</div>
						</button>
						<button name="submitAlt" type="button" class="botao" onClick="mudarperfil('GESTORES',login.value,'altgrp');">
						  <div align="center">GESTORES</div>
						</button>
						<!--- </td> --->
						<cfelseif ((form.frmgrpacessologin eq 'GESTORMASTER') or (form.frmgrpacessologin eq 'GESTORES' AND len(form.frmcoordena) gt 0) or (form.frmgrpacessologin eq 'ANALISTAS' AND len(form.frmcoordena) gt 0)) and (trim(form.area_usu) eq 'ANALISTAS')>
						<!--- <td width="8%"> --->
						<button name="submitAlt" type="button" class="botao" onClick="mudarperfil('INSPETORES',login.value,'altgrp');">
						  <div align="center">INSPETORES</div>
						</button>
						<button name="submitAlt" type="button" class="botao" onClick="mudarperfil('GESTORES',login.value,'altgrp');">
						  <div align="center">GESTORES</div>
						</button>
						<cfelseif ((form.frmgrpacessologin eq 'GESTORMASTER') or (form.frmgrpacessologin eq 'GESTORES' AND len(form.frmcoordena) gt 0) or (form.frmgrpacessologin eq 'ANALISTAS' AND len(form.frmcoordena) gt 0)) and (trim(form.area_usu) eq 'GESTORES')>
						<!--- <td width="8%"> --->
						<button name="submitAlt" type="button" class="botao" onClick="mudarperfil('INSPETORES',login.value,'altgrp');">
						  <div align="center">INSPETORES</div>
						</button>
						<button name="submitAlt" type="button" class="botao" onClick="mudarperfil('ANALISTAS',login.value,'altgrp');">
						  <div align="center">ANALISTAS</div>
						</button>						
						<!--- </td> --->				
						</cfif>
						</td>
						<td width="8%">
                      <cfif ((form.frmgrpacessologin eq 'GESTORMASTER') or (form.frmgrpacessologin eq 'GESTORES' AND len(form.frmcoordena) gt 0) or (form.frmgrpacessologin eq 'ANALISTAS' AND len(form.frmcoordena) gt 0) or (form.frmgrpacessologin eq 'INSPETORES' AND len(form.frmcoordena) gt 0)) >
						<cfset auxtam_lista = len(form.frmcoordena)>
							<cfset aux_lista = form.frmcoordena>
							<cfset aux_codse = "">
						
						<select name="lotSE" class="form">
						<cfif trim(form.frmgrpacessologin) eq 'GESTORMASTER' and #form.frmse# eq '01'>
						    <cfquery name="qCDR" datasource="#dsn_inspecao#">
								SELECT Dir_Codigo, Dir_Sigla FROM Diretoria
							</cfquery>
							<cfloop query="qCDR">
							    <cfset auxsigla= Ucase(trim(qCDR.Dir_Sigla))>
							   <option value="#qCDR.Dir_Codigo#" <cfif (#qCDR.Dir_Codigo# EQ #qPermissoes.Usu_DR#)>selected</cfif>>#auxsigla#</option>
							</cfloop>
	
						 <cfelseif trim(form.frmgrpacessologin) eq 'GESTORES' OR trim(form.frmgrpacessologin) eq 'INSPETORES' OR trim(form.frmgrpacessologin) eq 'ANALISTAS'>
							<cfloop from="1" to="#val(auxtam_lista) + 1# " index="i">
								 <cfif len(aux_codse) eq 2>
								  <cfquery name="qCDR" datasource="#dsn_inspecao#">
									SELECT Dir_Sigla FROM Diretoria  WHERE Dir_Codigo = '#aux_codse#'
								   </cfquery> 
								    <cfset auxsigla= Ucase(trim(qCDR.Dir_Sigla))>
								   <option value="#aux_codse#" selected <cfif (#aux_codse# EQ #qPermissoes.Usu_DR#)>selected</cfif>>#auxsigla#</option>
								   <cfset aux_codse = "">
								</cfif>
								<cfif mid(aux_lista,i,1) neq ",">
								  <cfset aux_codse = #aux_codse# & #mid(aux_lista,i,1)#>
								</cfif>
				           </cfloop>
					   </cfif>
					    </select>
						<button name="submitAlt" type="button" class="botao" onClick="mudarse(lotSE.value,login.value,'altse');">Alterar</button>
						
					</cfif>
					</td>
						<input type="hidden" name="area" value="#Usu_GrupoAcesso#">
						<input type="hidden" name="matricula" value="#Usu_Matricula#">
						<input type="hidden" name="login" value="#Usu_Login#">
						<input type="hidden" name="apelido" value="#Usu_Apelido#">
						<input type="hidden" name="email" value="#Usu_Email#">
						<input type="hidden" name="gerencia" value="#Usu_Lotacao#">
						<input type="hidden" name="outros" value="#Usu_Lotacao#">
						<td width="8%">
						  <div align="center">
						   <button name="submitAlt" type="button" class="botao" onClick="excluir(area.value,login.value,'exc');">
						  Excluir</button>
			        </div></td>
					
					<cfif form.area_usu eq 'GESTORES' or form.area_usu eq 'INSPETORES' OR form.area_usu eq 'ANALISTAS'>
					<td width="8%">
					<div align="center">
					  <input type="checkbox" name="cbmigrar" value="#trim(Usu_Matricula)#" onClick="migrar(this.value)">
				    </div>
					</td>
					<cfelse>
					<td width="8%"></td>
					</cfif>
					
			  </tr>
		    </form>
			<cfif scor eq 'f7f7f7'>
		      <cfset scor = 'CCCCCC'>
			<cfelse>
		      <cfset scor = 'f7f7f7'>
			</cfif>
		  </cfoutput>
	  </cfif>
	
	  <tr bgcolor="eeeeee">
	  <td colspan="8">&nbsp;</td>
	  </tr><a href="adicionar_permissao_rotinas_inspecao_novo.html">#DR#</a> 
</table>

	<!--- FIM DA ÁREA DE CONTEÚDO --->

	</table>

 </form>   

<form name="formvolta" method="post" action="adicionar_permissao_rotinas_inspecao.cfm?flush=true">
  <input name="sacao" type="hidden" id="sacao" value="voltar">
</form> 

<form name="formx" method="POST" action="CFC/rotinas_permissoes_in_out.cfc?method=altexc">
  <input name="ssuper" type="hidden" id="ssuper" value="<cfoutput>#form.dr#</cfoutput>">
  <input name="slabel" type="hidden" id="slabel" value="<cfoutput>#qacesso.Dir_Sigla#</cfoutput>">
  <input name="sarea_usu" type="hidden" id="sarea_usu" value="<cfoutput>#form.area_usu#</cfoutput>">
  <input name="sarea_ga" type="hidden" id="sarea_ga">
  <input name="smatr_usu" type="hidden" id="smatr_usu">
  <input name="slogin" type="hidden" id="slogin">
  <input name="sapelido_usu" type="hidden" id="sapelido_usu">
  <input name="semail_usu" type="hidden" id="semail_usu">
  <input name="sgerencia" type="hidden" id="sgerencia">
  <input name="soutros" type="hidden" id="soutros">
<!--- dados para inclusão --->
  <input name="sdominio" type="hidden" id="sdominio"> 
  <input name="slotacao" type="hidden" id="slotacao"> 

  <input name="slotacao_uni" type="hidden" id="slotacao_uni">
  <input name="slotacao_reop" type="hidden" id="slotacao_reop">
  <input name="slotacao_ges" type="hidden" id="slotacao_ges">
  <input name="slotacao_subreg" type="hidden" id="slotacao_subreg">
  <input name="slotacao_ger" type="hidden" id="slotacao_ger">
  <input name="slotacao_depto" type="hidden" id="slotacao_depto">
  <input name="slotacao_super" type="hidden" id="slotacao_super">
  <input name="frmgrpacessologin" type="hidden" id="frmgrpacessologin" value="<cfoutput>#form.frmgrpacessologin#</cfoutput>">
  <input name="frmcoordena" type="hidden" id="frmcoordena" value="<cfoutput>#form.frmcoordena#</cfoutput>">  
  <input name="frmse" type="hidden" value="<cfoutput>#form.frmse#</cfoutput>">
  
  <input name="sacao" type="hidden" id="sacao">
  <input name="svolta" type="hidden" id="svolta" value="../adicionar_permissao_rotinas_inspecao1.cfm">
  <input name="frmmigrar" type="hidden" value="">
  <input name="frmfazgestao" type="hidden" value="">
  <input name="frmmigrarpara" type="hidden" value="">
</form>
  <!--- Término da área de conteúdo --->
</body>
</html>

