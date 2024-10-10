<cfprocessingdirective pageEncoding ="utf-8"/>
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
</cfif>   
<!--- <cfset gestorMaster = TRIM('GESTORMASTER')/>--->
<cfset auxgrpacesso = 'DESENVOLVEDORES,GESTORMASTER,GOVERNANCA'> 
<cfquery name="qUsuarioGestorMaster" datasource="#dsn_inspecao#">
  SELECT DISTINCT Usu_GrupoAcesso FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#' and Usu_GrupoAcesso in ('#auxgrpacesso#')
</cfquery>
<cfquery name="rsGrpAcesso" datasource="#dsn_inspecao#">
  SELECT Usu_GrupoAcesso FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#'
</cfquery> 
<cfset grpacesso = ucase(Trim(rsGrpAcesso.Usu_GrupoAcesso))>
 <table width="261" border="0" cellpadding="0" cellspacing="0" bgcolor="003366" class="menu">  
 <!---  <table width="260" border="0" cellpadding="0" cellspacing="0">  --->
  <tr>
    <td width="261"><img src="toquinho.jpg" width="261" height="20" /></td>
  </tr>
  <tr>
    <td height="25">
	<table class="menu" width="100%" border="0" cellpadding="0">
	<cfif grpacesso neq "GOVERNANCA">
      <tr>
        <td colspan="2"><a href="#">CADASTRO/ALTERAÇÃO</a></td>
      </tr>
      <tr>
        <td>&nbsp;</td>
    <!---     <td>&nbsp;</td> --->
      </tr>
	 </cfif>
      <tr>
        <td width="90%">
		<table width="112%" border="0" cellpadding="0" cellspacing="4" class="menu">
		<cfif grpacesso neq "GOVERNANCA">
		 <tr>
            <td width="6%"><img src="smallArrow.gif" width="16" height="5" /></td>
            <td width="94%"><a href="index.cfm?opcao=permissao0">Unidades</a></td>
          </tr>
	  
         <!---  <tr>
            <td><img src="smallArrow.gif" width="16" height="5" /></td>
            <td width="94%"><a href="index.cfm?opcao=permissao2">&Aacute;reas</a></td>
          </tr>
          <tr>
            <td><img src="smallArrow.gif" width="16" height="5" /></td>
            <td width="94%"><a href="index.cfm?opcao=permissao3">&Oacute;rg&atilde;o Subordinador</a></td>
          </tr> --->
		  <!--- <tr>
		    <td><img src="smallArrow.gif" width="16" height="5" /></td>
            <td width="94%"><a href="index.cfm?opcao=permissao4">Unidades</a></td>
		  </tr> --->
		  <tr>
            <td><img src="smallArrow.gif" width="16" height="5" /></td>
            <td width="94%"><a href="index.cfm?opcao=permissao5">Funcionários</a></td>
          </tr>
	</cfif>		
	<cfif grpacesso neq "GOVERNANCA">  
		  <tr>
	        <td><img src="smallArrow.gif" width="16" height="5" /></td>
	        <td width="94%"><a href="index.cfm?opcao=permissao">Permissões - Usuários</a></td>
          </tr>
	 </cfif>
	  <cfif grpacesso eq "GESTORMASTER">
	   <tr>
		<td><img src="smallArrow.gif" width="16" height="5" /></td>
		<td width="94%"><a href="index.cfm?opcao=permissao15">Avisos</a></td>
	   </tr>
	  </cfif> 
  
<!--- 		  <cfif grpacesso eq "GESTORMASTER">
		   <tr>
	        <td><img src="smallArrow.gif" width="16" height="5" /></td>
	        <td width="94%"><a href="index.cfm?opcao=permissao16">Listar Itens Verifica&ccedil;&atilde;o</a></td>
           </tr>
		  </cfif> --->		  
<!--- 		  <tr>
		    <td><img src="smallArrow.gif" width="16" height="5" /></td>
            <td width="94%"><a href="index.cfm?opcao=permissao7">Acompanhamento</a></td>
		  </tr> ---> 		  
<!---       <cfif qUsuarioGestorMaster.recordcount neq 0 >
          <tr>
            <td><img src="smallArrow.gif" width="16" height="5" /></td>
            <td width="94%"><a href="cadastroGruposItens.cfm">Cadastro de Grupos e Itens (PLANO DE TESTE)</a></td>
          </tr>
      </cfif> --->



        </table></td>
      </tr>
<!---       <tr>
        <td>&nbsp;</td>
      </tr> --->
    </table>
	</td>
  </tr>
  <tr>
    <td><table width="98%" height="253" border="0" cellpadding="0" cellspacing="4" class="menu">
      <tr>
        <td colspan="2" rowspan=""><a href="#">AVALIAÇÃO DE CONTROLE INTERNO</a></td>
      </tr>
 <!---  
      <tr>
        <td>&nbsp;</td>
         <td>&nbsp;</td> 
      </tr>
---> 
      <tr>
        <td width="7%"><img src="smallArrow.gif" width="16" height="5" /></td>
        <td width="94%"><a href="index.cfm?opcao=inspecao">Relatórios Itens por Tipo Avaliação</a></td>
      </tr>
    <!---   <tr>
        <td><img src="smallArrow.gif" width="16" height="5" /></td>
        <td><a href="index.cfm?opcao=inspecao1">Pontos Controle Interno por Per&iacute;odo </a></td>
      </tr> --->
      <tr>
        <td><img src="smallArrow.gif" width="16" height="5" /></td>
        <td><a href="index.cfm?opcao=inspecao2">Controle das Manifestações</a></td>
      </tr>
      <tr>
        <td><img src="smallArrow.gif" width="16" height="5" /></td>
        <td><a href="index.cfm?opcao=inspecao3">Controle dos Pontos Baixados</a></td>
      </tr>
	  <tr>
		<td><img src="smallArrow.gif" width="16" height="5" /></td>
		<td width="94%"><a href="index.cfm?opcao=inspecao19">Relatório Acompanhamento Itens</a></td>
	  </tr>	
	  <cfif grpacesso neq "GOVERNANCA">
		   <tr>
			<td><img src="smallArrow.gif" width="16" height="5" /></td>
			<td><a href="index.cfm?opcao=inspecao16">Relatório Análise de Manifestação</a></td>
		  </tr>
	  </cfif>      
<!--- 	  <tr>
        <td><img src="smallArrow.gif" width="16" height="5" /></td>
        <td><a href="index.cfm?opcao=inspecao21">Efic&aacute;cia de Controle Interno das Unidades Operacionais (EFCI)</a></td>
      </tr> --->
	
<cfif grpacesso neq "ANALISTAS" and grpacesso neq "GOVERNANCA">	 	    
	  <tr> 
        <td><img src="smallArrow.gif" width="16" height="5" /></td>
        <td><a href="index.cfm?opcao=inspecao4">Relatório Itens por Causa Provável</a></td>
      </tr>
</cfif>	
 <!---	   <tr>
            <td width="7%"><img src="smallArrow.gif" width="16" height="5" /></td>
            <td><a href="index.cfm?opcao=inspecao5">Pontos Controle Interno - Estat�stica</td>
          </tr>
          <tr>
            <td><img src="smallArrow.gif" width="16" height="5" /></td>
            <td><a href="index.cfm?opcao=inspecao6">Pontos Pendentes - &Aacute;reas </a></td>
          </tr>
		  <tr>
            <td><img src="smallArrow.gif" width="16" height="5" /></td>
            <td><a href="index.cfm?opcao=inspecao7">Pontos Pendentes - &Oacute;rg&atilde;o Subordinador </a> </td>
          </tr>
		  <tr>
            <td><img src="smallArrow.gif" width="16" height="5" /></td>
            <td><a href="index.cfm?opcao=inspecao8">Pontos por Atividade</a> </td>
          </tr>
		  <tr>
            <td><img src="smallArrow.gif" width="16" height="5" /></td>
            <td><a href="index.cfm?opcao=inspecao9">Pontos Relevantes</a> </td>
          </tr>
		  <tr>
            <td><img src="smallArrow.gif" width="16" height="5" /></td>
            <td><a href="index.cfm?opcao=inspecao10">Pontos Corporativos</a> </td>
          </tr>
		  <tr>
            <td><img src="smallArrow.gif" width="16" height="5" /></td>
            <td><a href="index.cfm?opcao=inspecao14">Pontos Solucionados</a> </td>
          </tr>
		  <tr>
            <td><img src="smallArrow.gif" width="16" height="5" /></td>
            <td><a href="index.cfm?opcao=inspecao11"> por Tipo de Unidade</a> </td>
          </tr>
		  <tr>
            <td><img src="smallArrow.gif" width="16" height="5" /></td>
            <td><a href="index.cfm?opcao=inspecao12">Tempo de Solu��o por Ger�ncias</a> </td>
          </tr>
		  <tr>
		    <td><img src="smallArrow.gif" width="16" height="5" /></td>
		    <td><a href="index.cfm?opcao=inspecao13">Tempo de Solu&ccedil;&atilde;o por &Aacute;reas</a> </td>
	       </tr>
		 <tr>
            <td><img src="smallArrow.gif" width="16" height="5" /></td>
            <td><a href="index.cfm?opcao=inspecao15">Por Analista</a> </td>
         </tr>
	     <tr>
	       <td colspan="2">&nbsp;</td>
        </tr>
        <tr>
          <td colspan="2" rowspan=""><a href="#">Relat�rios</a></td>
       </tr>
	    <tr>
	       <td colspan="2">&nbsp;</td>
        </tr>
	   <tr>
	        <td><img src="smallArrow.gif" width="16" height="5" /></td>
	        <td><a href="index.cfm?opcao=permissao6">Preliminar</a></td>
       </tr>
	    <tr>
	      <td><img src="smallArrow.gif" width="16" height="5" /></td>
	      <td><a href="index.cfm?opcao=permissao7">Acompanhamento</a></td>
        </tr>
		<tr>
	      <td><img src="smallArrow.gif" width="16" height="5" /></td>
	      <td><a href="index.cfm?opcao=permissao8">Acompanhamento - DR</a></td>
        </tr>
	    <tr>
	      <td><img src="smallArrow.gif" width="16" height="5" /></td>
	      <td><a href="index.cfm?opcao=permissao9">Acompanhamento - �rea</a></td>
        </tr>
		<tr>
	      <td><img src="smallArrow.gif" width="16" height="5" /></td>
	      <td><a href="index.cfm?opcao=permissao10">Preliminar - �rea</a></td>
        </tr>
		<tr>
	      <td><img src="smallArrow.gif" width="16" height="5" /></td>
	      <td><a href="index.cfm?opcao=permissao11">Preliminar - DR</a></td>
        </tr>
		<tr>
	      <td><img src="smallArrow.gif" width="16" height="5" /></td>
	      <td><a href="index.cfm?opcao=permissao12">Preliminar por Objetivo</a></td>
        </tr>
		<tr>
	      <td><img src="smallArrow.gif" width="16" height="5" /></td>
	      <td><a href="index.cfm?opcao=permissao13">Acompanhamento por Objetivo</a></td>
        </tr>
	    <tr>
	      <td colspan="2">&nbsp;</td>
        </tr>
	    <tr>
	      <td colspan="2"><a href="#">Outros</a></td>
        </tr>
	    <tr>
	      <td colspan="2">&nbsp;</td>
        </tr>--->
    <cfif grpacesso eq "GESTORMASTER">
		  <tr>
	      <td><img src="smallArrow.gif" width="16" height="5" /></td>
	      <td><a href="index.cfm?opcao=permissao14">Processamento em Lote</a></td>
      </tr>
    </cfif>

		  <cfif grpacesso eq "GESTORMASTER" or grpacesso eq "GESTORES">
	   <tr>
		<td><img src="smallArrow.gif" width="16" height="5" /></td>
		<td width="94%"><a href="index.cfm?opcao=permissao18">Pesquisa Pós-Avaliação</a></td>
	   </tr>
	   <tr>
		<td><img src="smallArrow.gif" width="16" height="5" /></td>
		<td width="94%"><a href="index.cfm?opcao=permissao19">Unidades Avaliadas</a></td>
	   </tr>	
	   <tr>
		<td><img src="smallArrow.gif" width="16" height="5" /></td>
		<td width="94%"><a href="index.cfm?opcao=permissao20">Classificação Unidades</a></td>
	   </tr>
	   		      
	  </cfif>
	   <cfif grpacesso eq "GESTORES">
	   	<tr>		   
		<td><img src="smallArrow.gif" width="16" height="5" /></td>
		<td width="94%"><a href="index.cfm?opcao=permissao21">Solicitar Permuta Avaliação no PACIN</a></td>
	    </tr>
	    </cfif>	
	   <cfif grpacesso eq "GESTORMASTER">
      <tr>		   
         <td><img src="smallArrow.gif" width="16" height="5" /></td>
         <td width="94%"><a href="index.cfm?opcao=permissao22">Autorizar Permuta Avaliação no PACIN</a></td>
      </tr>		
        <tr>		   
          <td><img src="smallArrow.gif" width="16" height="5" /></td>
          <td width="94%"><a href="index.cfm?opcao=permissao27">Grupo/Item Reincidentes no PACIN</a></td>
        </tr>		         
	   </cfif>	
	  <cfif grpacesso eq 'GOVERNANCA'>
	  <tr>
		<td><img src="smallArrow.gif" width="16" height="5" /></td>
		<td width="94%"><a href="index.cfm?opcao=permissao20">Classificação Unidades</a></td>
	   </tr>
	  </cfif>
    </table>
   </td>
  </tr>
  <tr>
	 <td colspan="2">&nbsp;</td>
  </tr> 
  <tr>
    <td>
	<table width="98%" height="110" border="0" cellpadding="0" cellspacing="4" class="menu">
      <tr>
        <td colspan="2" rowspan=""><a href="#">INDICADORES DE CONTROLE INTERNO</a></td>
      </tr>
       <tr>
        <td>&nbsp;</td>
      </tr>
<!--- 	   <tr>
        <td>&nbsp;</td>
      </tr> --->
	   <tr>
		<td><img src="smallArrow.gif" width="16" height="5" /></td>
		<td width="94%"><a href="index.cfm?opcao=inspecao17">PRCI - Atend. ao Prazo de Resposta do Controle Interno</a></td>
	   </tr>

    <tr>
      <td><img src="smallArrow.gif" width="16" height="5" /></td>
      <td width="94%"><a href="index.cfm?opcao=inspecao20">SLNC - Solução de Não Conformidades</a></td>
    </tr>	
<!--- 	   <tr>
        <td>&nbsp;</td>
      </tr> --->

		<tr>		   
		<td><img src="smallArrow.gif" width="16" height="5" /></td>
		<td width="94%"><a href="index.cfm?opcao=inspecao22">DGCI - Desempenho Geral de Controle Interno</a></td>
	   </tr>	   		      
    </table>
   </td>
  </tr>
  <tr>
    <td class="branco" align="center" bgcolor="#FFFFFF"><div class="exibir">Login: <strong><cfoutput>#CGI.REMOTE_USER#</cfoutput></strong></div></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>
