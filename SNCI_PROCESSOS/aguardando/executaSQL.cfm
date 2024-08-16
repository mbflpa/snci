<cfprocessingdirective pageencoding = "utf-8">	
<cftransaction>
<cfquery datasource="#application.dsn_processos#" name="Deleta_pc_avaliacao_categoriasControles">
    DELETE FROM pc_avaliacao_categoriasControles
    FROM pc_avaliacao_categoriasControles
    INNER JOIN pc_avaliacoes on pc_avaliacoes.pc_aval_id = pc_avaliacao_categoriasControles.pc_aval_id
   
</cfquery>

<cfquery datasource="#application.dsn_processos#" name="Deleta_pc_avaliacao_melhoria_categoriasControles">
    DELETE FROM pc_avaliacao_melhoria_categoriasControles 
    FROM pc_avaliacao_melhoria_categoriasControles 
    INNER JOIN pc_avaliacao_melhorias on pc_avaliacao_melhorias.pc_aval_melhoria_id = pc_avaliacao_melhoria_categoriasControles .pc_aval_melhoria_id
    INNER JOIN pc_avaliacoes on pc_avaliacoes.pc_aval_id = pc_avaliacao_melhorias.pc_aval_melhoria_num_aval
    
</cfquery>

<cfquery datasource="#application.dsn_processos#" name="Deleta_pc_avaliacao_orientacao_categoriasControles">
    DELETE FROM pc_avaliacao_orientacao_categoriasControles 
    FROM pc_avaliacao_orientacao_categoriasControles 
    INNER JOIN pc_avaliacao_orientacoes on pc_avaliacao_orientacoes.pc_aval_orientacao_id = pc_avaliacao_orientacao_categoriasControles.pc_aval_orientacao_id
    INNER JOIN pc_avaliacoes on pc_avaliacoes.pc_aval_id = pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval
   
</cfquery>

<cfquery datasource="#application.dsn_processos#" name="Deleta_pc_avaliacao_riscos">
    DELETE FROM pc_avaliacao_riscos
    FROM pc_avaliacao_riscos
    INNER JOIN pc_avaliacoes on pc_avaliacoes.pc_aval_id = pc_avaliacao_riscos.pc_aval_id
   
</cfquery>

<cfquery datasource="#application.dsn_processos#" name="Deleta_pc_avaliacao_tiposControles">
    DELETE FROM pc_avaliacao_tiposControles
    FROM pc_avaliacao_tiposControles
    INNER JOIN pc_avaliacoes on pc_avaliacoes.pc_aval_id = pc_avaliacao_tiposControles.pc_aval_id
   
</cfquery>

<cfquery datasource="#application.dsn_processos#" name="Deleta_pc_avaliacao_criterioReferencia">
    DELETE FROM pc_avaliacao_criterioReferencia
</cfquery>

</cftransaction>
   



 