package de.hs.demo.azure;

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;

@Entity
public class Person extends PanacheEntity {
    @Column(name = "given_name")
    public String givenName;
    @Column(name = "family_name")
    public String familyName;

    @Override
    public String toString() {
        return "Person{" +
                "givenName='" + givenName + '\'' +
                ", familyName='" + familyName + '\'' +
                '}';
    }
}
