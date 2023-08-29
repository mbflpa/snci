<cfprocessingdirective pageEncoding ="utf-8"/>  
<cfif isDefined("Form.acao") and #form.acao# is 'salvar'>
<cfoutput>
	<cfquery datasource="#dsn_inspecao#" name="rsExiste">
	 select Pes_Inspecao from Pesquisa_Pos_Avaliacao  where Pes_Inspecao ='#form.ninsp#'
	</cfquery>
	<cfif rsExiste.recordcount lte 0>
		<cfquery datasource="#dsn_inspecao#">
		INSERT INTO Pesquisa_Pos_Avaliacao (Pes_Inspecao) VALUES ('#form.ninsp#')
		</cfquery>	
	</cfif>
	<!--- update dos campos --->
	<cfquery datasource="#dsn_inspecao#">
		UPDATE Pesquisa_Pos_Avaliacao SET Pes_dtultatu = convert(char, getdate(), 120)
		, Pes_GestorNome = '#form.UsuApelido#'
		, Pes_NomeUnidade = '#form.unidnome#'
		, Pes_username = '#CGI.REMOTE_USER#'
		<cfif form.tipoper is 1>
		, Pes_vat_rac = '#form.frmopcao1a#'
		, Pes_vat_roa = '#form.frmopcao1b#'
		</cfif>
		<cfif form.tipoper is 2>
		, Pes_col_pc = '#form.frmopcao2a#'
		, Pes_col_rc = '#form.frmopcao2b#'
		</cfif>		
		<cfif form.tipoper is 3>
		, Pes_dis_pe = '#form.frmopcao3a#'
		, Pes_dis_re = '#form.frmopcao3b#'
		</cfif>		
		<cfif form.tipoper is 4>
		, Pes_tra_rmc = '#form.frmopcao4a#'
		, Pes_tra_rt = '#form.frmopcao4b#'
		</cfif>	
		<cfif form.tipoper is 5>
		, Pes_trt_rt = '#form.frmopcao5a#'
		, Pes_trt_rcgc = '#form.frmopcao5b#'
		, Pes_trt_pt = '#form.frmopcao5c#'
		, Pes_trt_gdt = '#form.frmopcao5d#'		
		</cfif>		
		<cfif form.tipoper is 6>
		, Pes_sls_rsl = '#form.frmopcao6a#'
		, Pes_sls_rsa = '#form.frmopcao6b#'
		, Pes_sls_gse = '#form.frmopcao6c#'	
		</cfif>	
		<cfif form.tipoper is 7>
		, Pes_gat_gfeo = '#form.frmopcao7a#'
		</cfif>							
		WHERE Pes_Inspecao='#FORM.ninsp#'
	</cfquery>
	<script>window.close()</script>
</cfoutput> 
</cfif>

<!--- <cfset CurrentPage=GetFileFromPath(GetTemplatePath())> --->
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<script type="text/javascript" src="ckeditor\ckeditor.js"></script>

<script type="text/javascript">
<cfinclude template="mm_menu.js">

//reinicia o ckeditor para inibir o erro de retornar conteúdo vazio no textarea
function CKupdate(){
    for ( instance in CKEDITOR.instances )
    CKEDITOR.instances[instance].updateElement();
}
</script>
</head>

<body> 
<!--- Pesquisa1.cfm?ninsp=#auxinsp#&codunid=#qUnid.Usu_Lotacao#&unidnome=#qUnid.Und_Descricao#&tipoper=4',900,600)" --->
	<cfquery name="rsPesq" datasource="#dsn_inspecao#">
	SELECT Pes_Inspecao, Pes_GestorNome, Pes_NomeUnidade, Pes_vat_rac, Pes_vat_roa, Pes_col_pc, Pes_col_rc, Pes_dis_pe, Pes_dis_re, Pes_tra_rmc, Pes_tra_rt, Pes_trt_rt, Pes_trt_rcgc, Pes_trt_pt, Pes_trt_gdt, Pes_sls_rsl, Pes_sls_rsa, Pes_sls_gse, Pes_gat_gfeo
	FROM Pesquisa_Pos_Avaliacao
	WHERE Pes_Inspecao = '#ninsp#'
	</cfquery>

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_Apelido, Usu_GrupoAcesso
	from usuarios 
	where Usu_login = '#cgi.REMOTE_USER#'
</cfquery>
<cfset Pesvatrac=''>
<cfset Pesvatroa=''>
<cfset Pescolpc=''>
<cfset Pescolrc=''>
<cfset Pesdispe=''>
<cfset Pesdisre=''>
<cfset Pestrarmc=''>
<cfset Pestrart=''>
<cfset Pestrtrcgc=''>
<cfset Pestrtpt=''>
<cfset Pestrtgdt=''>
<cfset Pesslsrsl=''>
<cfset Pesslsrsa=''>
<cfset Pesslsgse=''>
<cfset Pesgatgfeo=''>

<cfoutput>
	<cfif rsPesq.recordcount gt 0>
		<cfset Pesvatrac=#rsPesq.Pes_vat_rac#>
		<cfset Pesvatroa=#rsPesq.Pes_vat_roa#>
		<cfset Pescolpc=#rsPesq.Pes_col_pc#>
		<cfset Pescolrc=#rsPesq.Pes_col_rc#>
		<cfset Pesdispe=#rsPesq.Pes_dis_pe#>
		<cfset Pesdisre=#rsPesq.Pes_dis_re#>
		<cfset Pestrarmc=#rsPesq.Pes_tra_rmc#>
		<cfset Pestrart=#rsPesq.Pes_tra_rt#>
		<cfset Pestrtrcgc=#rsPesq.Pes_trt_rcgc#>
		<cfset Pestrtpt=#rsPesq.Pes_trt_pt#>
		<cfset Pestrtgdt=#rsPesq.Pes_trt_gdt#>
		<cfset Pesslsrsl=#rsPesq.Pes_sls_rsl#>
		<cfset Pesslsrsa=#rsPesq.Pes_sls_rsa#>
		<cfset Pesslsgse=#rsPesq.Pes_sls_gse#>
		<cfset Pesgatgfeo=#rsPesq.Pes_gat_gfeo#>
	</cfif>	
</cfoutput>

 <cfinclude template="cabecalho.cfm">
<table width="58%" height="439"  align="center" bordercolor="f7f7f7">
  
  <tr>
    <td height="20" colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td height="10" colspan="2"><table width="851" height="20">
      <tr>
        <td width="755"><div align="center"><strong class="titulo1">PESQUISA PÓS AVALIAÇÃO </strong></div>		</td>
        </tr>
    </table></td>
  </tr>
<cfoutput>
  <form name="form1" method="post" onSubmit="return validarform()" action="pesquisa1.cfm">
  <cfset exibirnuminspecao = ''>
<!--- <cfoutput query="qResposta"> --->
    
	  <tr bgcolor="##FFFFFF" class="exibir">
	    <td colspan="2">&nbsp;</td>
      </tr>
	  
	  <tr bgcolor="eeeeee" class="exibir">
	    <td colspan="2"><div align="left"><strong class="exibir">Unidade&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: #codunid# - #unidnome#</strong></div></td>
      </tr>
 	  
	  <tr bgcolor="eeeeee" class="exibir">
	    <td colspan="2"><div align="left"><strong class="exibir">N&ordm; Avaliação&nbsp;: #ninsp#</strong></div>	   </td>
    </tr>

	  <tr bgcolor="eeeeee" class="exibir">
	    <td colspan="2">&nbsp;</td>
    </tr>
<!--- opcao1  --->
<cfif tipoper is 1>
	  <tr bgcolor="eeeeee" class="exibir">
      <td colspan="2"><strong>Operação: Varejo e Atendimento&nbsp;- Realizar atendimento, comercialização e atividades operacionais em agências.</strong></td>
      </tr>
 <td width="1173"></tr>
	<tr class="exibir">
	  <td height="14" colspan="3" align="center" bgcolor="eeeeee">&nbsp;</td>
    </tr>
	<tr class="exibir">
	  <td height="31" colspan="3" align="center" bgcolor="eeeeee"><div align="left"><strong>&nbsp;Realizar Atendimento, Comercialização &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(De Produtos e Serviços)</strong> </div></td>
    </tr>

	<tr>
	  <td colspan="3" align="center" bgcolor="eeeeee" class="exibir"><div align="left">
	    <textarea name="frmopcao1a" cols="120" rows="5" wrap="VIRTUAL" class="form" id="frmopcao1a">#Pesvatrac#</textarea>
      </div></td>
    </tr>
	<tr>
	  <td colspan="3" align="center" bgcolor="eeeeee" class="exibir"><div align="left"><strong>Atividades Operacionais em Agências &nbsp;&nbsp;&nbsp;(De Natureza não Comercial)</strong></div></td>
    </tr>
	<tr>
         <td colspan="3" align="center" bgcolor="eeeeee" class="exibir"><div align="left">
           <textarea name="frmopcao1b" cols="120" rows="5" wrap="VIRTUAL" class="form" id="frmopcao1b">#Pesvatroa#</textarea>
         </div></td>
    </tr>
</cfif>		
<!--- opcao2 --->
<cfif tipoper is 2>
	  <tr bgcolor="eeeeee" class="exibir">
      <td colspan="2"><strong>Operação: Coleta &nbsp;- Realizar coleta de objetos em clientes.</strong></td>
      </tr>
 <td width="1173"></tr>
	<tr class="exibir">
	  <td height="14" colspan="3" align="center" bgcolor="eeeeee">&nbsp;</td>
    </tr>
	<tr class="exibir">
	  <td height="31" colspan="3" align="center" bgcolor="eeeeee"><div align="left"><strong>&nbsp;Planejar Coleta &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(Definir os procedimentos e recursos necessários para a coleta dos objetos em clientes)</strong> </div></td>
    </tr>
	<tr>
	  <td colspan="3" align="center" bgcolor="eeeeee" class="exibir"><div align="left">
	    <textarea name="frmopcao2a" cols="120" rows="5" wrap="VIRTUAL" class="form" id="frmopcao2a">#Pescolpc#</textarea>
      </div></td>
    </tr>
	<tr>
	  <td colspan="3" align="center" bgcolor="eeeeee" class="exibir"><div align="left"><strong>&nbsp;Realizar Coleta&nbsp;&nbsp;&nbsp;(Executar o plano de coleta e as atividades pós-coleta)</strong></div></td>
    </tr>
	<tr>
         <td colspan="3" align="center" bgcolor="eeeeee" class="exibir"><div align="left">
           <textarea name="frmopcao2b" cols="120" rows="5" wrap="VIRTUAL" class="form" id="frmopcao2b">#Pescolrc#</textarea>
         </div></td>
    </tr>	
</cfif>

<!--- opcao3 --->
<cfif tipoper is 3>
	  <tr bgcolor="eeeeee" class="exibir">
      <td colspan="2"><strong>Operação: Distribuição &nbsp;- Realizar preparação e entrega dos objetos na última milha.</strong></td>
      </tr>
 <td width="1173"></tr>
	<tr class="exibir">
	  <td height="14" colspan="3" align="center" bgcolor="eeeeee">&nbsp;</td>
    </tr>
	<tr class="exibir">
	  <td height="31" colspan="3" align="center" bgcolor="eeeeee"><div align="left"><strong>&nbsp;Planejar Entrega &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(Definir os procedimentos e recursos necessários para a entrega dos objetos em clientes)</strong> </div></td>
    </tr>
	<tr>
	  <td colspan="3" align="center" bgcolor="eeeeee" class="exibir"><div align="left">
	    <textarea name="frmopcao3a" cols="120" rows="5" wrap="VIRTUAL" class="form" id="frmopcao3a">#Pesdispe#</textarea>
      </div></td>
    </tr>
	<tr>
	  <td colspan="3" align="center" bgcolor="eeeeee" class="exibir"><div align="left"><strong>&nbsp;Realizar Entrega &nbsp;&nbsp;&nbsp;(Realizar a entrega e as atividades pós-distribuição (baixas, devoluções, registros, etc.))</strong></div></td>
    </tr>
	<tr>
         <td colspan="3" align="center" bgcolor="eeeeee" class="exibir"><div align="left">
           <textarea name="frmopcao3b" cols="120" rows="5" wrap="VIRTUAL" class="form" id="frmopcao3b">#Pesdisre#</textarea>
         </div></td>
    </tr>	
</cfif>

<!--- opcao4 --->
<cfif tipoper is 4>
	  <tr bgcolor="eeeeee" class="exibir">
      <td colspan="2"><strong>Operação: Transporte &nbsp;- Realizar separação e a preparação dos objetos, execução, monitoramento do transporte e a tranferência de carga.</strong></td>
      </tr>
 <td width="1173"></tr>
	<tr class="exibir">
	  <td height="14" colspan="3" align="center" bgcolor="eeeeee">&nbsp;</td>
    </tr>
	<tr class="exibir">
	  <td height="31" colspan="3" align="center" bgcolor="eeeeee"><div align="left"><strong>&nbsp;Realizar Movimentação de Carga  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(Receber/liberar carga nos terminais de carga e unidades de tratamento, realizar triagem, carregamento/descarregamento e liberação do veículo)</strong> </div></td>
    </tr>
	<tr>
	  <td colspan="3" align="center" bgcolor="eeeeee" class="exibir"><div align="left">
	    <textarea name="frmopcao4a" cols="120" rows="5" wrap="VIRTUAL" class="form" id="frmopcao4a">#Pestrarmc#</textarea>
      </div></td>
    </tr>
	<tr>
	  <td colspan="3" align="center" bgcolor="eeeeee" class="exibir"><div align="left"><strong>&nbsp;Realizar Transferência &nbsp;&nbsp;&nbsp;(Realizar operação de transporte de carga entre unidades, incluindo a operação em qualquer um dos modais utilizados)</strong></div></td>
    </tr>
	<tr>
         <td colspan="3" align="center" bgcolor="eeeeee" class="exibir"><div align="left">
           <textarea name="frmopcao4b" cols="120" rows="5" wrap="VIRTUAL" class="form" id="frmopcao4b">#Pestrart#</textarea>
         </div></td>
    </tr>	
</cfif>

<!--- opcao5 --->
<cfif tipoper is 5>
	  <tr bgcolor="eeeeee" class="exibir">
      <td colspan="2"><strong>Operação: Tratamento &nbsp;- Realizar separação e a preparação dos objetos para transferência.</strong></td>
      </tr>
 <td width="1173"></tr>
	<tr class="exibir">
	  <td height="14" colspan="3" align="center" bgcolor="eeeeee">&nbsp;</td>
    </tr>
	<tr class="exibir">
	  <td height="31" colspan="3" align="center" bgcolor="eeeeee"><div align="left"><strong>&nbsp;Realizar Tratamento&nbsp;&nbsp;&nbsp;(Definir procedimento para separação de itens, tanto de forma manual, semi-automática e automática, de acordo com o critério definido o Plano de Triagem)</strong> </div></td>
    </tr>
	<tr>
	  <td colspan="3" align="center" bgcolor="eeeeee" class="exibir"><div align="left">
	    <textarea name="frmopcao5a" cols="120" rows="5" wrap="VIRTUAL" class="form" id="frmopcao5a">#Pestrtrcgc#</textarea>
      </div></td>
    </tr>
	<tr>
	  <td colspan="3" align="center" bgcolor="eeeeee" class="exibir"><div align="left"><strong>&nbsp;Realizar Captação de Grandes Clientes &nbsp;(Realizar o recebimento da carga dos grandes clientes, efetuar postagem, manuseio e lançamento nos sistemas e disponibilizar carga para triagem.)</strong></div></td>
    </tr>
	<tr>
         <td colspan="3" align="center" bgcolor="eeeeee" class="exibir"><div align="left">
           <textarea name="frmopcao5b" cols="120" rows="5" wrap="VIRTUAL" class="form" id="frmopcao5b">#Pestrtpt#</textarea>
         </div></td>
    </tr>	
	<tr>
	  <td colspan="3" align="center" bgcolor="eeeeee" class="exibir"><div align="left"><strong>&nbsp;Planejar tratamento  &nbsp;(Planejar e definir recursos, procedimentos e equipamentos necessários ao tratamento da carga postal)</strong></div></td>
    </tr>
	<tr>
         <td colspan="3" align="center" bgcolor="eeeeee" class="exibir"><div align="left">
           <textarea name="frmopcao5c" cols="120" rows="5" wrap="VIRTUAL" class="form" id="frmopcao5c">#Pestrtgdt#</textarea>
         </div></td>
    </tr>	
<tr>
	  <td colspan="3" align="center" bgcolor="eeeeee" class="exibir"><div align="left"><strong>&nbsp;Gerir Desempenho do Tratamento  &nbsp;(Efetuar a gestão do desempenho do processo de tratamento de objetos nas unidades, adotando ações corretivas quando necessário.)</strong></div></td>
    </tr>
	<tr>
         <td colspan="3" align="center" bgcolor="eeeeee" class="exibir"><div align="left">
           <textarea name="frmopcao5d" cols="120" rows="5" wrap="VIRTUAL" class="form" id="frmopcao5d">#Pesslsrsl#</textarea>
         </div></td>
    </tr>		
</cfif>
<!--- opcao6 --->
<cfif tipoper is 6>
	  <tr bgcolor="eeeeee" class="exibir">
      <td colspan="2"><strong>Operação: Serviços de Logística e Suprimento &nbsp;- Realizar a operação de serviços logísticos adicionais a cadeia postal e gerir suprimento de itens estocáveis.</strong></td>
      </tr>
 <td width="1173"></tr>
	<tr class="exibir">
	  <td height="14" colspan="3" align="center" bgcolor="eeeeee">&nbsp;</td>
    </tr>
	<tr class="exibir">
	  <td height="31" colspan="3" align="center" bgcolor="eeeeee"><div align="left"><strong>&nbsp;Realizar Serviços Logísticos &nbsp;(Realizar recebimento de carga, armazenagem, gerenciamento de estoque de fornecedor, separação de pedidos, expedição de carga e serviçõs de entregas especiais)</strong> </div></td>
    </tr>
	<tr>
	  <td colspan="3" align="center" bgcolor="eeeeee" class="exibir"><div align="left">
	    <textarea name="frmopcao6a" cols="120" rows="5" wrap="VIRTUAL" class="form" id="frmopcao6a">#Pesslsrsa#</textarea>
      </div></td>
    </tr>
	<tr>
	  <td colspan="3" align="center" bgcolor="eeeeee" class="exibir"><div align="left"><strong>&nbsp;Realizar Suporte Aduaneiro &nbsp;(Realizar prestação de suporte operacional e administrativo ao desembaraço de importações, exportações e trânsito com a Receita Federal)</strong></div></td>
    </tr>
	<tr>
         <td colspan="3" align="center" bgcolor="eeeeee" class="exibir"><div align="left">
           <textarea name="frmopcao6b" cols="120" rows="5" wrap="VIRTUAL" class="form" id="frmopcao6b">#Pesslsgse#</textarea>
         </div></td>
    </tr>	
	<tr>
	  <td colspan="3" align="center" bgcolor="eeeeee" class="exibir"><div align="left"><strong>&nbsp;Gerir Suprimentos Estocáveis   &nbsp;(Gerir a cadeia de suprimentos de itens estocáveis)</strong></div></td>
    </tr>
	<tr>
         <td colspan="3" align="center" bgcolor="eeeeee" class="exibir"><div align="left">
           <textarea name="frmopcao6c" cols="120" rows="5" wrap="VIRTUAL" class="form" id="frmopcao6c">#Pesgatgfeo#</textarea>
         </div></td>
    </tr>	
</cfif>  
<!--- opcao7 --->
<cfif tipoper is 7>
	  <tr bgcolor="eeeeee" class="exibir">
      <td colspan="2"><strong>Operação: Gestão de Ativos &nbsp;- Disponibilizar os ativos necessários à execução do planejamento operacional (veículos, equipamentos, unitizadores, etc.)</strong></td>
      </tr>
 <td width="1173"></tr>
	<tr class="exibir">
	  <td height="14" colspan="3" align="center" bgcolor="eeeeee">&nbsp;</td>
    </tr>
	<tr class="exibir">
	  <td height="31" colspan="3" align="center" bgcolor="eeeeee"><div align="left"><strong>&nbsp;Gerir Frota e equipamentos Operacionais  &nbsp;(Realizar a gestão de veículos, contêineres e equipamentos de carregamento, assim como empilhadeiras, pallets e demais equipamentos de movimentação de carga nas unidades operacionais.)</strong> </div></td>
    </tr>
	<tr>
	  <td colspan="3" align="center" bgcolor="eeeeee" class="exibir"><div align="left">
	    <textarea name="frmopcao7a" cols="120" rows="5" wrap="VIRTUAL" class="form" id="frmopcao7a"></textarea>
      </div></td>
    </tr>
</cfif>
  <cfset btnSN = ''>
  <cfif isDefined("url.consulta") and (url.consulta is 'S')>
	<cfset btnSN = 'Disabled'>
  </cfif>
<cfif ucase(trim(qAcesso.Usu_GrupoAcesso)) neq 'UNIDADES'>
	<cfset btnSN = 'Disabled'>
  </cfif>  
    <tr bgcolor="eeeeee">
      <td height="32" colspan="3" align="center" valign="middle"><table width="798">
        <tr>
		<td><div align="center">
            <input name="Submit1" type="button" class="form" id="Submit1" value="Fechar" onClick="window.close()">
          </div></td>
          <td><div align="center">
            <input name="Submit" type="submit" class="form" value="Confirmar" onClick="document.form1.acao.value='salvar'" <cfoutput>#btnSN#</cfoutput>>
          </div></td>
          
        </tr>
      </table></td>
      </tr>
  

 <input type="hidden" name="ninsp" value="<cfoutput>#ninsp#</cfoutput>">
 <input type="hidden" name="tipoper" value="<cfoutput>#tipoper#</cfoutput>">
<input type="hidden" name="unidnome" value="<cfoutput>#unidnome#</cfoutput>">
<input type="hidden" name="UsuApelido" value="<cfoutput>#qAcesso.Usu_Apelido#</cfoutput>">
<input type="hidden" id="acao" name="acao" value="">
 </form>
 </cfoutput>
  <!--- Fim area de conteudo --->
</table>
</body>

<script>
function validarform(){
    var frm = document.forms[0];
//	alert(frm.tipoper.value);
	
//======================================	
	if (frm.tipoper.value == 1 && frm.frmopcao1a.value=='' && frm.frmopcao1b.value=='') {
	  alert('Faltou informar um ou mais campo(s)!');
	  frm.frmopcao1a.focus();
	  return false;
	}
//======================================
	if (frm.tipoper.value == 2 && frm.frmopcao2a.value=='' && frm.frmopcao2b.value=='') {
	  alert('Faltou informar um ou mais campo(s)!');
	  frm.frmopcao2a.focus();
	  return false;
	}
//======================================
	if (frm.tipoper.value == 3 && frm.frmopcao3a.value=='' && frm.frmopcao3b.value=='') {
	  alert('Faltou informar um ou mais campo(s)!');
	  frm.frmopcao3a.focus();
	  return false;
	}
//======================================	
	if (frm.tipoper.value == 4 && frm.frmopcao4a.value=='' && frm.frmopcao4b.value=='') {
	  alert('Faltou informar um ou mais campo(s)!');
	  frm.frmopcao4a.focus();
	  return false;
	}
//======================================	
	if (frm.tipoper.value == 5 && (frm.frmopcao5a.value=='' && frm.frmopcao5b.value=='' && frm.frmopcao5c.value=='' && frm.frmopcao5d.value=='')) {
	  alert('Faltou informar um ou mais campo(s)!');
	  frm.frmopcao5a.focus();
	  return false;
	}
//======================================	
	if (frm.tipoper.value == 6 && (frm.frmopcao6a.value=='' && frm.frmopcao6b.value=='' && frm.frmopcao6c.value=='')) {
	  alert('Faltou informar um ou mais campo(s)!');
	  frm.frmopcao6a.focus();
	  return false;
	}	
	if (frm.tipoper.value == 7 && frm.frmopcao7a.value=='') {
	  alert('Faltou informar campo!');
	  frm.frmopcao7a.focus();
	  return false;
	}	
}
</script>

</html>



