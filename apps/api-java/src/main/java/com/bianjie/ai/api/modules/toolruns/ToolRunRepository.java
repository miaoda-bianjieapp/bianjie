package com.bianjie.ai.api.modules.toolruns;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ToolRunRepository extends JpaRepository<ToolRunEntity, String> {

    List<ToolRunEntity> findAllByOrderByUpdatedAtDesc();
}
