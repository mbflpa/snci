<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif> 

 <table width="260" border="0" cellpadding="0" cellspacing="0" bgcolor="#003366" class="menu">
  <tr>
    <td><img src="toquinho.jpg" width="261" height="20" /></td>
  </tr> 
  <tr>
    <td height="25"><table class="menu"width="100%" border="0" cellpadding="0">
      <tr>
        <td colspan="2"><a href="#">Cadastro</a></td>
      </tr>
      <tr>
        <td colspan="2">&nbsp;</td>
      </tr>
      <tr>   
        <td width="90%"><table width="100%" border="0" cellpadding="0" cellspacing="4" class="menu">
          <tr>
            <td width="6%"><img src="smallArrow.gif" width="16" height="5" /></td>
            <td width="94%"><a href="index.cfm?opcao=permissao2">&Aacute;reas</a></td>
          </tr>
          <tr>
            <td><img src="smallArrow.gif" width="16" height="5" /></td>
            <td width="94%"><a href="index.cfm?opcao=permissao3">Órgão Subordinador</a></td>
          </tr>
		  <tr>
		    <td><img src="smallArrow.gif" width="16" height="5" /></td>
            <td width="94%"><a href="index.cfm?opcao=permissao4">Unidades</a></td>
		  </tr>
		  <tr>
            <td><img src="smallArrow.gif" width="16" height="5" /></td>
            <td width="94%"><a href="index.cfm?opcao=permissao5">Funcionários</a></td>
          </tr>	
		  <tr>
	        <td><img src="smallArrow.gif" width="16" height="5" /></td>
	        <td><a href="index.cfm?opcao=permissao">Permiss&otilde;es - Usuários</a></td>
          </tr> 		  
        </table></td>
      </tr>      
      <tr>
        <td>&nbsp;</td>       
      </tr>
    </table></td>
  </tr>
  <tr>  
    <td><table width="100%" border="0" cellpadding="0" cellspacing="4" class="menu">      
      <tr>
        <td colspan="2" rowspan=""><a href="#">Auditorias</a></td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
      <tr>	    
        <td width="7%"><img src="smallArrow.gif" width="16" height="5" /></td>
        <td width="94%"><a href="index.cfm?opcao=inspecao">Pontos de Auditoria por Unidade </a></td>
      </tr>
      <tr>
        <td><img src="smallArrow.gif" width="16" height="5" /></td>
        <td><a href="index.cfm?opcao=inspecao1">Pontos de Auditoria por Per&iacute;odo </a></td>
      </tr>
      <tr>
        <td><img src="smallArrow.gif" width="16" height="5" /></td>
        <td><a href="index.cfm?opcao=inspecao2">Controle das Manifestações </a></td>
      </tr>
      <tr>
        <td><img src="smallArrow.gif" width="16" height="5" /></td>
        <td><a href="index.cfm?opcao=inspecao3">Pontos de Auditoria por Órgão Subordinador</a></td>
      </tr>
      <tr>
        <td><img src="smallArrow.gif" width="16" height="5" /></td>
        <td><a href="index.cfm?opcao=inspecao4">Pontos de Auditoria por &Aacute;rea Gestora </a></td>
      </tr>	
	      <tr>
            <td width="7%"><img src="smallArrow.gif" width="16" height="5" /></td>
            <td><a href="index.cfm?opcao=inspecao5">Pontos de Auditoria - Estatística</td>
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
            <td><a href="index.cfm?opcao=inspecao11">Auditorias por Tipo de Unidade</a> </td>
          </tr>
		  <tr>
            <td><img src="smallArrow.gif" width="16" height="5" /></td>
            <td><a href="index.cfm?opcao=inspecao12">Tempo de Solução por Gerências</a> </td>
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
          <td colspan="2" rowspan=""><a href="#">Relatórios</a></td>		  
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
	      <td><a href="index.cfm?opcao=permissao9">Acompanhamento - Área</a></td>
        </tr>
		<tr>
	      <td><img src="smallArrow.gif" width="16" height="5" /></td>
	      <td><a href="index.cfm?opcao=permissao10">Preliminar - Área</a></td>
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
        </tr>
	    <tr>
	      <td><img src="smallArrow.gif" width="16" height="5" /></td>
	      <td><a href="index.cfm?opcao=permissao1">Excluir Auditoria</a></td>
        </tr>	                              
    </table>
   </td>
  </tr>
  <tr>
	 <td colspan="2">&nbsp;</td>
  </tr>   
  <tr>
    <td class="branco" align="center" bgcolor="#FFFFFF"><div class="exibir">Login: <strong><cfoutput>#CGI.REMOTE_USER#</cfoutput></strong></div></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>
