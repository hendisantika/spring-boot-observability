package id.my.hendisantika.loanservice;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.testcontainers.containers.MySQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.boot.test.context.SpringBootTest.WebEnvironment.RANDOM_PORT;

@Testcontainers
@SpringBootTest(
        properties = {
                "management.endpoint.health.show-details=always",
                "spring.datasource.url=jdbc:tc:mysql:9.1.0:///loan_service",
        },
        webEnvironment = RANDOM_PORT
)
class LoanServiceApplicationTests {

    @Container
    private static final MySQLContainer<?> mysqlContainer = new MySQLContainer<>("mysql:9.1.0")
            .withDatabaseName("loan_service")
            .withUsername("yu71")
            .withPassword("53cret");

    @Test
    void testMySQLContainerIsRunning() {
        assertThat(mysqlContainer.isRunning()).isTrue();
    }

}
