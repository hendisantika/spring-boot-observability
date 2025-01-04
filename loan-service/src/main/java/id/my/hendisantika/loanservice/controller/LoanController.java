package id.my.hendisantika.loanservice.controller;

import id.my.hendisantika.loanservice.dto.LoanDto;
import id.my.hendisantika.loanservice.service.LoanService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * Project : spring-boot-observability
 * User: hendisantika
 * Email: hendisantika@gmail.com
 * Telegram : @hendisantika34
 * Date: 04/01/25
 * Time: 23.36
 * To change this template use File | Settings | File Templates.
 */
@RestController
@RequestMapping("/api/loans")
@RequiredArgsConstructor
public class LoanController {

    private final LoanService loanService;

    @GetMapping
    @ResponseStatus(HttpStatus.OK)
    public List<LoanDto> listAllLoans() {
        return loanService.listAllLoans();
    }

    @PostMapping
    public String applyLoan(@RequestBody LoanDto loanDto) {
        return loanService.applyLoan(loanDto);
    }
}
