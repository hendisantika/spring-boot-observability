package id.my.hendisantika.loanservice.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * Created by IntelliJ IDEA.
 * Project : spring-boot-observability
 * User: hendisantika
 * Email: hendisantika@gmail.com
 * Telegram : @hendisantika34
 * Date: 04/01/25
 * Time: 08.36
 * To change this template use File | Settings | File Templates.
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Loan {
    private Long id;
    private String loanId;
    private String customerName;
    private int customerId;
    private BigDecimal amount;
    private LoanStatus loanStatus;

    public static Loan from(LoanDto loanDto) {
        if (loanDto.getLoanId() == null && loanDto.getLoanStatus() == null) {
            return Loan.builder()
                    .loanId(loanDto.getLoanId())
                    .amount(loanDto.getAmount())
                    .customerId(loanDto.getCustomerId())
                    .customerName(loanDto.getCustomerName())
                    .build();
        }
        return Loan.builder()
                .loanId(loanDto.getLoanId())
                .amount(loanDto.getAmount())
                .customerId(loanDto.getCustomerId())
                .customerName(loanDto.getCustomerName())
                .build();
    }

}
