package com.sineth.server.dto;

import java.util.UUID;
import java.time.LocalDateTime;

public class TeacherResponse {
  private UUID id;
  private String f_name;
  private String l_name;
  private String gender;
  private LocalDateTime birthdate;
  private String user_id;
  private String profile_picture_url;

  public TeacherResponse(UUID id, String f_name, String l_name, String gender, LocalDateTime birthdate, String user_id, String profile_picture_url) {
    this.id = id;
    this.f_name = f_name;
    this.l_name = l_name;
    this.gender = gender;
    this.birthdate = birthdate;
    this.user_id = user_id;
    this.profile_picture_url = profile_picture_url;
  }

  public UUID getId() {
    return this.id;
  }

  public String getF_name() {
    return this.f_name;
  }

  public String getL_name() {
    return this.l_name;
  }

  public String getGender() {
    return this.gender;
  }

  public LocalDateTime getBirthdate() {
    return this.birthdate;
  }

  public String getUser_id() {
    return this.user_id;
  }

  public String getProfile_picture_url() {
    return this.profile_picture_url;
  }

}
